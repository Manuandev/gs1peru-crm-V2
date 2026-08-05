// lib/features/solicitudes/presentation/widgets/completar/solicitud_carga_masiva_view.dart

import 'dart:io';

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudCargaMasivaView extends StatefulWidget {
  // Máximo de participantes de la negociación de origen — null si esta
  // solicitud no viene de una negociación con cantidad ya definida (ver
  // SolicitudFormState.cantidadEsperada). Cuando no es null, el import se
  // recorta a los cupos que todavía quedan libres.
  final int? cantidadEsperada;

  const SolicitudCargaMasivaView({super.key, this.cantidadEsperada});

  @override
  State<SolicitudCargaMasivaView> createState() =>
      _SolicitudCargaMasivaViewState();
}

class _SolicitudCargaMasivaViewState extends State<SolicitudCargaMasivaView> {
  static const _extensionesPermitidas = ['xlsx', 'xls', 'xlsm'];
  static const _tamanioMaximoBytes = 10 * 1024 * 1024;

  PlatformFile? _archivo;
  List<ParticipanteLocal> _participantesParseados = [];
  String? _errorParseo;
  bool _descargando = false;
  bool _subiendo = false;

  Future<void> _seleccionarArchivo() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _extensionesPermitidas,
      withData: true,
    );
    final archivo = resultado?.files.single;
    if (archivo == null) return;

    final extension = archivo.extension?.toLowerCase();
    if (!_extensionesPermitidas.contains(extension) ||
        archivo.bytes == null) {
      if (mounted) {
        AppSnackBar.error(
          context,
          'Solo se permiten archivos Excel (.xlsx, .xls, .xlsm)',
        );
      }
      return;
    }
    if (archivo.size > _tamanioMaximoBytes) {
      if (mounted) {
        AppSnackBar.error(context, 'El archivo supera las 10 MB permitidas.');
      }
      return;
    }

    setState(() {
      _archivo = archivo;
      _participantesParseados = [];
      _errorParseo = null;
    });
    _parsearArchivo(archivo);
  }

  void _quitarArchivo() {
    setState(() {
      _archivo = null;
      _participantesParseados = [];
      _errorParseo = null;
    });
  }

  // Parseo 100% local (mismo enfoque que GestionRegistroEventoEdit.js en la
  // web, que lee el Excel con XLSX.js en el navegador sin llamar al
  // backend) — columnas del Excel, en orden: [0] Tipo documento,
  // [1] N° documento, [2] Nacionalidad, [3] Nombres, [4] Apellido paterno,
  // [5] Apellido materno, [6] Cargo, [7] País (prefijo celular),
  // [8] N° celular, [9] Correo. Los textos se cruzan contra el catálogo
  // real (CatalogsBloc) para resolver los ids — si algo no matchea, el
  // participante igual se agrega con ese campo vacío (las validaciones de
  // campo quedan para una siguiente pasada, pedido explícito del usuario).
  void _parsearArchivo(PlatformFile archivo) {
    final catalogState = context.read<CatalogsBloc>().state;
    if (catalogState is! CatalogsLoaded) {
      setState(
        () => _errorParseo = 'Los catálogos aún no cargan, intenta de nuevo.',
      );
      return;
    }

    try {
      final libro = Excel.decodeBytes(archivo.bytes!);
      if (libro.tables.isEmpty) {
        setState(() => _errorParseo = 'El archivo no cumple con el formato.');
        return;
      }

      final hoja = libro.tables[libro.tables.keys.first]!;
      final filas = hoja.rows;

      final idTipoParticipantePagante =
          catalogState.tiposParticipante
              .where((t) => !t.esInvitado)
              .firstOrNull
              ?.id ??
          '';

      final cantidadEsperada = widget.cantidadEsperada;
      final yaAgregados = context
          .read<ParticipantesCubit>()
          .state
          .participantes
          .length;
      final cupoRestante = cantidadEsperada == null
          ? null
          : (cantidadEsperada - yaAgregados).clamp(0, cantidadEsperada);

      String celda(List<Data?> fila, int indice) => indice < fila.length
          ? (fila[indice]?.value?.toString().trim() ?? '')
          : '';

      final parseados = <ParticipanteLocal>[];
      var filasIgnoradasPorCupo = 0;

      for (var i = 1; i < filas.length; i++) {
        final fila = filas[i];

        final tipoDocTexto = celda(fila, 0);
        final numDoc = celda(fila, 1);
        final nacionalidadTexto = celda(fila, 2);
        final nombres = celda(fila, 3);
        final apellidoPaterno = celda(fila, 4);
        final apellidoMaterno = celda(fila, 5);
        final cargo = celda(fila, 6);
        final paisTexto = celda(fila, 7);
        final nroCelular = celda(fila, 8);
        final correo = celda(fila, 9);

        // Fila completamente vacía — se ignora, no cuenta como registro.
        final vacia = [
          tipoDocTexto,
          numDoc,
          nombres,
          correo,
        ].every((v) => v.isEmpty);
        if (vacia) continue;

        if (cupoRestante != null && parseados.length >= cupoRestante) {
          filasIgnoradasPorCupo++;
          continue;
        }

        final tipoDocTextoNorm = tipoDocTexto.toUpperCase();
        final tipoDoc = catalogState.tiposDocumento
            .where(
              (t) =>
                  t.abreviatura.toUpperCase() == tipoDocTextoNorm ||
                  t.nombre.toUpperCase() == tipoDocTextoNorm,
            )
            .firstOrNull;
        final nacionalidad = catalogState.nacionalidades
            .where((n) => n.nombre.toUpperCase() == nacionalidadTexto.toUpperCase())
            .firstOrNull;
        final pais = catalogState.paises
            .where((p) => p.nombre.toUpperCase() == paisTexto.toUpperCase())
            .firstOrNull;

        parseados.add(
          ParticipanteLocal(
            id: 0, // ParticipantesCubit.agregar reasigna el id real al subir
            tipoDocId: tipoDoc?.id ?? '',
            tipoDoc: tipoDoc?.abreviatura ?? tipoDocTexto,
            numDoc: numDoc,
            nacionalidadId: nacionalidad?.id ?? '',
            nacionalidad: nacionalidad?.nombre ?? nacionalidadTexto,
            nombres: nombres,
            apellidoPaterno: apellidoPaterno,
            apellidoMaterno: apellidoMaterno,
            correo: correo,
            cargo: cargo,
            celular: nroCelular,
            celularCodigoTelefono: pais?.codigoTelefono ?? '',
            tipoParticipante: idTipoParticipantePagante,
            importe: 0,
          ),
        );
      }

      setState(() {
        _participantesParseados = parseados;
        _errorParseo = parseados.isEmpty
            ? 'El archivo importado no tiene registros.'
            : null;
      });

      if (filasIgnoradasPorCupo > 0 && mounted) {
        AppSnackBar.warning(
          context,
          'Se alcanzó el máximo de $cantidadEsperada participante(s) — '
          '$filasIgnoradasPorCupo fila(s) del Excel no se importaron.',
        );
      }
    } catch (_) {
      setState(() => _errorParseo = 'El archivo no cumple con el formato.');
    }
  }

  Future<void> _descargarPlantilla() async {
    setState(() => _descargando = true);
    try {
      final useCase = DescargarPlantillaCargaMasivaUseCase(
        context.read<SolicitudRepository>(),
      );
      final bytes = await useCase();

      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/Carga_Masiva_Participantes.xlsm';
      await File(savePath).writeAsBytes(bytes);
      await OpenFilex.open(savePath);
    } on AppException catch (e) {
      if (mounted) AppSnackBar.error(context, e.message);
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, 'No se pudo descargar la plantilla.');
      }
    } finally {
      if (mounted) setState(() => _descargando = false);
    }
  }

  void _subirParticipantes() {
    if (_participantesParseados.isEmpty) return;
    setState(() => _subiendo = true);

    final cubit = context.read<ParticipantesCubit>();
    for (final p in _participantesParseados) {
      cubit.agregar(p);
    }

    AppSnackBar.success(
      context,
      '${_participantesParseados.length} participante(s) agregado(s).',
    );
    context.goBack();
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
      onPop: () => context.goBack(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Carga masiva de participantes',
      appBarLeadingButtons: [
        IconButton(
          onPressed: () => context.goBack(),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PasoSection(
                    numero: 1,
                    titulo: 'Descarga la plantilla',
                    descripcion:
                        'Descarga la plantilla Excel en blanco y completa la información requerida.',
                    contenido: ContenidoPaso1(
                      descargando: _descargando,
                      onDescargar: _descargarPlantilla,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const PasoSection(
                    numero: 2,
                    titulo: 'Completa la plantilla',
                    descripcion:
                        'Los campos obligatorios son las columnas sombreadas en amarillo.',
                    contenido: ContenidoPaso2(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PasoSection(
                    numero: 3,
                    titulo: 'Carga los participantes',
                    descripcion:
                        'Adjunta el archivo Excel completado para importar los participantes.',
                    contenido: ContenidoPaso3(
                      archivo: _archivo,
                      onArchivoSeleccionado: _seleccionarArchivo,
                      onArchivoQuitado: _quitarArchivo,
                    ),
                  ),
                  if (_errorParseo != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    BannerError(mensaje: _errorParseo!),
                  ],
                  if (_participantesParseados.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    VistaPreviaImportacion(
                      participantes: _participantesParseados,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Botones pie ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomSecondaryButton(
                    text: 'Cancelar',
                    backgroundColor: AppColors.brandRaspberryAccessible,
                    onPressed: () => context.goBack(),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: CustomPrimaryButton(
                    text: 'Subir participantes',
                    icon: AppIcons.upload,
                    isLoading: _subiendo,
                    onPressed:
                        _participantesParseados.isNotEmpty && !_subiendo
                        ? _subirParticipantes
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
