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
                  _PasoSection(
                    numero: 1,
                    titulo: 'Descarga la plantilla',
                    descripcion:
                        'Descarga la plantilla Excel en blanco y completa la información requerida.',
                    contenido: _ContenidoPaso1(
                      descargando: _descargando,
                      onDescargar: _descargarPlantilla,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _PasoSection(
                    numero: 2,
                    titulo: 'Completa la plantilla',
                    descripcion:
                        'Los campos obligatorios son las columnas sombreadas en amarillo.',
                    contenido: _ContenidoPaso2(),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PasoSection(
                    numero: 3,
                    titulo: 'Carga los participantes',
                    descripcion:
                        'Adjunta el archivo Excel completado para importar los participantes.',
                    contenido: _ContenidoPaso3(
                      archivo: _archivo,
                      onArchivoSeleccionado: _seleccionarArchivo,
                      onArchivoQuitado: _quitarArchivo,
                    ),
                  ),
                  if (_errorParseo != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _BannerError(mensaje: _errorParseo!),
                  ],
                  if (_participantesParseados.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _VistaPreviaImportacion(
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

// ── Sección de paso numerado ──────────────────────────────────────────────────

class _PasoSection extends StatelessWidget {
  final int numero;
  final String titulo;
  final String descripcion;
  final Widget contenido;

  const _PasoSection({
    required this.numero,
    required this.titulo,
    required this.descripcion,
    required this.contenido,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$numero',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                descripcion,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              contenido,
            ],
          ),
        ),
      ],
    );
  }
}

// ── Paso 1: Descargar plantilla ───────────────────────────────────────────────

class _ContenidoPaso1 extends StatelessWidget {
  final bool descargando;
  final VoidCallback onDescargar;

  const _ContenidoPaso1({
    required this.descargando,
    required this.onDescargar,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          onPressed: descargando ? null : onDescargar,
          icon: descargando
              ? const SizedBox(
                  width: AppSizing.iconActionSm,
                  height: AppSizing.iconActionSm,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSizing.spinnerStrokeSmall,
                  ),
                )
              : const Icon(AppIcons.download, size: AppSizing.iconActionSm),
          label: Text(
            descargando ? 'Descargando...' : 'Descargar plantilla Excel',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
            textStyle: AppTextStyles.labelSmall.copyWith(
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Paso 2: Tabla de ejemplo ──────────────────────────────────────────────────

class _ContenidoPaso2 extends StatelessWidget {
  const _ContenidoPaso2();

  static const _columnas = [
    'TIPO\nDOC.',
    'N° DOC.',
    'NACIONAL.',
    'NOMBRES',
    'AP.\nPATERNO',
    'AP.\nMATERNO',
    'EMAIL',
    'PAÍS',
    'TELÉFONO',
    'PART.',
  ];

  static const _filas = [
    [
      'DNI',
      '29383293',
      'PERUANA',
      'MIGUEL',
      'CÁCERES',
      'MÉNDEZ',
      'mcaceres@gmail.com',
      'Perú',
      '5037613284',
      'SI',
    ],
    [
      'CARNET',
      '29934323',
      'BRASILEÑA',
      'JOAO',
      'ROQUE',
      'VARGAS',
      'joao.roque@gmail.com',
      'Brasil',
      '50379150391',
      'SI',
    ],
    [
      'DNI',
      '29043223',
      'PERUANA',
      'KARLA',
      'MARIA',
      'CONTRERAS',
      'karlomaria@gmail.com',
      'Perú',
      '50377269772',
      'SI',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildTabla(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.importacionObligatoria,
                border: Border.all(color: AppColors.border),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Campos obligatorios',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabla() {
    return Table(
      border: TableBorder.all(color: AppColors.border, width: 0.5),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: AppColors.importacionObligatoria,
          ),
          children: _columnas
              .map(
                (col) => _CeldaTabla(
                  texto: col,
                  negrita: true,
                  alineacion: TextAlign.center,
                ),
              )
              .toList(),
        ),
        ..._filas.map(
          (fila) => TableRow(
            children: fila.map((cel) => _CeldaTabla(texto: cel)).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Paso 3: Área de carga ─────────────────────────────────────────────────────

class _ContenidoPaso3 extends StatelessWidget {
  final PlatformFile? archivo;
  final VoidCallback onArchivoSeleccionado;
  final VoidCallback onArchivoQuitado;

  const _ContenidoPaso3({
    required this.archivo,
    required this.onArchivoSeleccionado,
    required this.onArchivoQuitado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AreaCarga(
          archivo: archivo,
          onSeleccionar: onArchivoSeleccionado,
          onQuitar: onArchivoQuitado,
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: Text(
            'Formato permitido: .xlsx, .xls, .xlsm (Máx. 10 MB)',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _AreaCarga extends StatelessWidget {
  final PlatformFile? archivo;
  final VoidCallback onSeleccionar;
  final VoidCallback onQuitar;

  const _AreaCarga({
    required this.archivo,
    required this.onSeleccionar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final tieneArchivo = archivo != null;

    return CustomPaint(
      painter: _DashedBorderPainter(
        color: AppColors.primary,
        borderRadius: AppSizing.radiusMd,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryWithOpacity(0.04),
          borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tieneArchivo ? AppIcons.fileExcel : AppIcons.upload,
              size: AppSizing.iconXl,
              color: tieneArchivo ? AppColors.success : AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              tieneArchivo
                  ? archivo!.name
                  : 'Arrastra y suelta el archivo aquí',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleSmall.copyWith(
                color: tieneArchivo ? AppColors.success : AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            if (!tieneArchivo) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'o selecciona el archivo desde tu dispositivo',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: tieneArchivo ? onQuitar : onSeleccionar,
              icon: Icon(
                tieneArchivo ? AppIcons.close : AppIcons.attach,
                size: AppSizing.iconActionSm,
              ),
              label: Text(
                tieneArchivo ? 'Quitar archivo' : 'Adjuntar archivo Excel',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: tieneArchivo
                    ? AppColors.error
                    : AppColors.primary,
                side: BorderSide(
                  color: tieneArchivo ? AppColors.error : AppColors.primary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                ),
                textStyle: AppTextStyles.labelSmall.copyWith(
                  fontWeight: AppTextStyles.weightSemiBold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Vista previa de importación ───────────────────────────────────────────────

class _VistaPreviaImportacion extends StatelessWidget {
  final List<ParticipanteLocal> participantes;

  const _VistaPreviaImportacion({required this.participantes});

  static const _columnas = [
    'TIPO DOC.',
    'N° DOC.',
    'NOMBRE COMPLETO',
    'CARGO',
    'NACIONALIDAD',
    'CELULAR',
    'CORREO',
  ];

  @override
  Widget build(BuildContext context) {
    final filas = participantes
        .take(3)
        .map(
          (p) => [
            p.tipoDoc,
            p.numDoc,
            p.nombreCompleto,
            p.cargo,
            p.nacionalidad,
            [
              p.celularCodigoTelefono,
              p.celular,
            ].where((s) => s.isNotEmpty).join(' '),
            p.correo,
          ],
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                AppIcons.visibility,
                color: AppColors.primary,
                size: AppSizing.iconMd,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vista previa de importación',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: AppTextStyles.weightBold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Revisa la información antes de subir los participantes.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ChipConteo(count: participantes.length, valido: true),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Tabla de vista previa
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTabla(filas),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Nota inferior
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.ui1,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  AppIcons.infoCircle,
                  size: AppSizing.iconSm,
                  color: AppColors.info,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    'Se muestran hasta 3 filas en la vista previa. '
                    'Se importarán ${participantes.length} participante(s) en total — '
                    'las validaciones de campo se agregarán más adelante.',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabla(List<List<String>> filas) {
    return Table(
      border: TableBorder.all(color: AppColors.border, width: 0.5),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: [
        TableRow(
          children: _columnas
              .map(
                (col) => _CeldaTabla(
                  texto: col,
                  negrita: true,
                  alineacion: TextAlign.center,
                ),
              )
              .toList(),
        ),
        ...filas.map(
          (fila) => TableRow(
            children: fila.map((cel) => _CeldaTabla(texto: cel)).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Banner de error de parseo ─────────────────────────────────────────────────

class _BannerError extends StatelessWidget {
  final String mensaje;

  const _BannerError({required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(26),
        border: Border.all(color: AppColors.error),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            AppIcons.warning,
            size: AppSizing.iconSm,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              mensaje,
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip de conteo válidos/errores ────────────────────────────────────────────

class _ChipConteo extends StatelessWidget {
  final int count;
  final bool valido;

  const _ChipConteo({required this.count, required this.valido});

  @override
  Widget build(BuildContext context) {
    final color = valido ? AppColors.success : AppColors.error;
    final icono = valido ? AppIcons.checkCircle : AppIcons.warning;
    final label = valido ? '$count válidos' : '$count errores';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: AppSizing.iconSm, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: AppTextStyles.weightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Celda genérica de tabla ───────────────────────────────────────────────────

class _CeldaTabla extends StatelessWidget {
  final String texto;
  final bool negrita;
  final TextAlign alineacion;

  const _CeldaTabla({
    required this.texto,
    this.negrita = false,
    this.alineacion = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Text(
        texto,
        textAlign: alineacion,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: negrita
              ? AppTextStyles.weightSemiBold
              : AppTextStyles.weightRegular,
        ),
      ),
    );
  }
}

// ── Borde a trazos para el área de carga ─────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  const _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    canvas.drawPath(_buildDashPath(path, 6.0, 4.0), paint);
  }

  Path _buildDashPath(Path source, double dashLen, double gapLen) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      double d = 0;
      bool draw = true;
      while (d < metric.length) {
        final step = draw ? dashLen : gapLen;
        final end = d + step;
        if (draw) {
          result.addPath(
            metric.extractPath(d, end < metric.length ? end : metric.length),
            Offset.zero,
          );
        }
        d += step;
        draw = !draw;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color || old.borderRadius != borderRadius;
}
