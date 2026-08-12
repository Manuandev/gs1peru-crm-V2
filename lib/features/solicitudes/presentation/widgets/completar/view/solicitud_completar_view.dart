// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/lead/index_lead.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

part 'solicitud_completar_view_carga.dart';
part 'solicitud_completar_view_guardado.dart';

class SolicitudCompletarView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;
  // Avanza al paso 2 (Participantes) dentro del mismo SolicitudWizardView —
  // ya no navega a una ruta aparte, ver CLAUDE.md "Wizard de una sola page".
  final VoidCallback onContinuar;
  // Sale del wizard por completo (Cancelar, con confirmación) — pop de la
  // page raíz del wizard, no un paso interno.
  final VoidCallback onCancelar;

  const SolicitudCompletarView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
    required this.onContinuar,
    required this.onCancelar,
  });

  @override
  State<SolicitudCompletarView> createState() => _SolicitudCompletarViewState();
}

class _SolicitudCompletarViewState extends State<SolicitudCompletarView> {
  // Valida los campos obligatorios (*) del paso in situ — cada CustomTextField/
  // CustomComboField con `validator` se pone en rojo con su propio mensaje al
  // fallar `_formKey.currentState.validate()`, en vez de un snackbar genérico.
  final _formKey = GlobalKey<FormState>();

  // Arranca en false para que ningún campo se marque en rojo mientras el
  // asesor recién está escribiendo — la validación solo debe empezar al
  // presionar "Siguiente" por primera vez (pedido de negocio). Una vez que
  // eso pasa, se pone en true para que los campos ya marcados se limpien
  // solos al corregirlos, sin esperar a un nuevo "Siguiente" (ver
  // _onContinuar).
  bool _autovalidar = false;

  // true mientras se trae la solicitud del backend (task 'DT') — bloquea el
  // formulario para que los combos (que solo leen su valor inicial una vez,
  // en su propio initState) no se construyan antes de tener los datos.
  bool _cargando = true;

  // true mientras se guarda el borrador (botón "Guardar")
  bool _guardando = false;

  // Pasos del guardado (Guardar solicitud → Subiendo voucher/O.C.) para
  // el overlay de progreso — ver solicitud_progreso_guardado.dart.
  final SolicitudProgreso _progreso = SolicitudProgreso();

  // Nombre del voucher/O.C. ya guardado en el backend (viene de
  // getSolicitudDetalle() al reabrir la solicitud) — vive acá, no en
  // SolicitudFormCubit, porque _construirDatosSolicitante() se llama en
  // cada sync y necesita un valor estable que sobreviva a que el usuario
  // edite otros campos. "Quitar" en un archivo existente limpia esto (sin
  // llamar al backend — no hay una operación de borrado sin reemplazo, solo
  // reemplazo subiendo uno nuevo del mismo tipo, ver CLAUDE.md).
  String _archivoVoucherExistente = '';
  String _archivoOCExistente = '';

  // Canal seleccionado (single-select) — catálogo real vía CatalogsBloc
  CanalExpoItem? _canalSeleccionado;

  // Detalle libre del canal — solo se pide/muestra cuando el canal
  // seleccionado tiene esDetallado == true (ej. "Otros"). Se manda como
  // NOMBRE_CANAL en vez de la descripción del canal (ver
  // _construirDatosSolicitante) — el id del canal (ID_CANAL) sigue viajando
  // normal.
  final _ctrlCanalDetalle = TextEditingController();

  // País del código telefónico del celular — catálogo real vía CatalogsBloc
  PaisItem? _paisCelular;

  // Switches — opciones del solicitante
  bool _solicitanteParticipante = false;
  bool _facturarAlSolicitante = false;

  // Labels/ids de combos capturados desde SeccionDatosSolicitante
  String _tipoDocId = '';
  String _tipoDocLabel = '';
  String _nacionalidadId = '';
  String _nacionalidadLabel = '';
  String _sexoId = '';

  // Controladores — Datos del solicitante
  final _ctrlNumDoc = TextEditingController();
  final _ctrlNombres = TextEditingController();
  final _ctrlApellidoPaterno = TextEditingController();
  final _ctrlApellidoMaterno = TextEditingController();
  final _ctrlCargo = TextEditingController();
  final _ctrlCelular = TextEditingController();
  final _ctrlCorreo = TextEditingController();

  // Controladores — Información comercial
  final _ctrlRuc = TextEditingController();
  final _ctrlRazonSocial = TextEditingController();

  // Autocompletado por documento (Clientes/BuscarDocumento) — mismo servicio
  // que participante_form_sheet.dart, usado en dos campos independientes de
  // este paso: Número documento (Datos del solicitante) y RUC (Información
  // comercial, solo llena Razón Social).
  final _documentoService = DocumentoExternoService();
  bool _buscandoDocSolicitante = false;
  String _ultimoDocSolicitanteBuscado = '';
  bool _buscandoRuc = false;
  String _ultimoRucBuscado = '';

  void _onCampoTexto() {
    setState(() {});
    _sincronizarCubit();
  }

  // Empuja el draft actual (ids de combos + texto de inputs, aunque estén
  // vacíos) a SolicitudFormCubit en cada cambio — así el paso 1 nunca pierde
  // datos al moverse a otro paso dentro del wizard, sin depender de que se
  // presione "Continuar"/"Guardar". No sincroniza mientras `_cargando` es
  // true (evita pisar el draft con datos a medio poblar durante el fetch).
  void _sincronizarCubit() {
    if (_cargando || !mounted) return;
    context.read<SolicitudFormCubit>().guardarSolicitante(
      _construirDatosSolicitante(_paisCelular),
    );
  }

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _ctrlNumDoc,
      _ctrlNombres,
      _ctrlApellidoPaterno,
      _ctrlApellidoMaterno,
      _ctrlCargo,
      _ctrlCelular,
      _ctrlCorreo,
      _ctrlRuc,
      _ctrlRazonSocial,
      _ctrlCanalDetalle,
    ]) {
      ctrl.addListener(_onCampoTexto);
    }
    _cargarDetalle();
  }

  Future<void> _adjuntarArchivo(bool esVoucher) async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: SolicitudExtensiones.archivosAdjuntos,
      withData: true, // asegura PlatformFile.bytes en todas las plataformas
    );
    final archivo = resultado?.files.single;
    if (archivo == null) return;

    final extension = archivo.extension?.toLowerCase();
    if (!SolicitudExtensiones.archivosAdjuntos.contains(extension)) {
      if (mounted) {
        AppSnackBar.error(context, 'Solo se permiten archivos PDF o imágenes');
      }
      return;
    }

    if (!mounted) return;
    final formCubit = context.read<SolicitudFormCubit>();
    if (esVoucher) {
      formCubit.guardarArchivoVoucher(archivo);
    } else {
      formCubit.guardarArchivoOC(archivo);
    }
  }

  // Si hay un archivo de esta sesión (recién adjuntado), lo quita. Si no —
  // pero sí hay uno ya guardado en el backend — solo limpia la referencia
  // local (no hay operación de borrado sin reemplazo en el backend, ver
  // CLAUDE.md); "Adjuntar" vuelve a habilitarse para elegir uno nuevo, que
  // al guardar reemplaza al anterior (el SP borra por NUMSOL+TIPO antes de
  // insertar).
  void _quitarArchivo(bool esVoucher) {
    final formCubit = context.read<SolicitudFormCubit>();
    if (esVoucher) {
      if (formCubit.state.archivoVoucher != null) {
        formCubit.quitarArchivoVoucher();
      } else {
        setState(() => _archivoVoucherExistente = '');
      }
    } else {
      if (formCubit.state.archivoOC != null) {
        formCubit.quitarArchivoOC();
      } else {
        setState(() => _archivoOCExistente = '');
      }
    }
    _sincronizarCubit();
  }

  Future<void> _confirmarCancelar() async {
    final confirmado = await context.showConfirmDialog(
      title: 'Cancelar solicitud',
      message: '¿Desea cancelar el proceso de solicitud?',
      confirmText: 'Sí, cancelar',
      cancelText: 'No',
    );
    if (confirmado && mounted) widget.onCancelar();
  }

  @override
  void dispose() {
    _ctrlNumDoc.dispose();
    _ctrlNombres.dispose();
    _ctrlApellidoPaterno.dispose();
    _ctrlApellidoMaterno.dispose();
    _ctrlCargo.dispose();
    _ctrlCelular.dispose();
    _ctrlCorreo.dispose();
    _ctrlRuc.dispose();
    _ctrlRazonSocial.dispose();
    _ctrlCanalDetalle.dispose();
    _progreso.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const AppLoadingView();
    }

    final formState = context.watch<SolicitudFormCubit>().state;
    final tipoPersona = formState.tipoPersona;
    final catalogState = context.watch<CatalogsBloc>().state;
    // Solo se muestran los 2 primeros canales del catálogo — pedido del
    // usuario, el resto no se ofrece como opción en "¿Cómo se enteró del
    // evento?".
    final canales = catalogState is CatalogsLoaded
        ? catalogState.canalesExpo
        : const <CanalExpoItem>[];
    final paises = catalogState is CatalogsLoaded
        ? catalogState.paises
        : const <PaisItem>[];
    final idPaisDefecto = catalogState is CatalogsLoaded
        ? catalogState.valoresDefecto.idPais
        : '';
    final paisCelular =
        _paisCelular ??
        (paises.isEmpty
            ? null
            : paises.where((p) => p.id == idPaisDefecto).firstOrNull ??
                  paises.first);

    return BlocListener<ParticipantesCubit, ParticipantesState>(
      // Se dispara solo en la transición "existía un participante marcado
      // esSolicitante" → "ya no existe ninguno" — el caso real es que el
      // asesor lo borró a mano desde el paso 2 (Participantes). Si eso pasa,
      // el switch de acá debe reflejarlo y apagarse solo — si no, quedaría
      // encendido pero sin ningún participante real detrás, y el próximo
      // "Continuar" lo volvería a crear de la nada.
      listenWhen: (previous, current) =>
          previous.participantes.any((p) => p.esSolicitante) &&
          !current.participantes.any((p) => p.esSolicitante),
      listener: (context, state) {
        if (_solicitanteParticipante) {
          setState(() => _solicitanteParticipante = false);
          _sincronizarCubit();
        }
      },
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Form(
                    key: _formKey,
                    // Desactivada hasta el primer "Siguiente" — nada se marca
                    // en rojo solo por escribir/tocar un campo. Una vez que
                    // "Siguiente" marca los campos en rojo (_autovalidar
                    // pasa a true), se limpian solos al corregirlos, sin
                    // esperar a un nuevo intento de "Siguiente".
                    autovalidateMode: _autovalidar
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Toggle tipo persona ─────────────────────────────
                        Align(
                          alignment: Alignment.centerRight,
                          child: SolicitudToggleTipoPersona(
                            valor: tipoPersona,
                            habilitado: widget.modoEdicion,
                            onChanged: (v) => context
                                .read<SolicitudFormCubit>()
                                .cambiarTipoPersona(v),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),

                        // ── ¿Cómo se enteró del evento? ────────────────────
                        SeccionCanalEvento(
                          canales: canales,
                          seleccionado: _canalSeleccionado,
                          habilitado: widget.modoEdicion,
                          onSeleccionar: (canal) {
                            if (!widget.modoEdicion) return;
                            setState(() {
                              _canalSeleccionado =
                                  _canalSeleccionado?.id == canal.id
                                  ? null
                                  : canal;
                            });
                            _sincronizarCubit();
                          },
                          ctrlDetalle: _ctrlCanalDetalle,
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // ── Botones de adjuntos ────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BotonAdjuntar(
                                label: 'Voucher',
                                archivo: formState.archivoVoucher,
                                nombreExistente: _archivoVoucherExistente,
                                habilitado: widget.modoEdicion,
                                onAdjuntar: () => _adjuntarArchivo(true),
                                onQuitar: () => _quitarArchivo(true),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: BotonAdjuntar(
                                label: 'OC',
                                archivo: formState.archivoOC,
                                nombreExistente: _archivoOCExistente,
                                habilitado: widget.modoEdicion,
                                onAdjuntar: () => _adjuntarArchivo(false),
                                onQuitar: () => _quitarArchivo(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        // ── Tooltip informativo — 3 partes de la solicitud ─
                        const TooltipPartesSolicitud(),
                        const SizedBox(height: AppSpacing.sm),

                        // ── Datos del solicitante ──────────────────────────
                        SeccionDatosSolicitante(
                          habilitado: widget.modoEdicion,
                          ctrlNumDoc: _ctrlNumDoc,
                          ctrlNombres: _ctrlNombres,
                          ctrlApellidoPaterno: _ctrlApellidoPaterno,
                          ctrlApellidoMaterno: _ctrlApellidoMaterno,
                          ctrlCargo: _ctrlCargo,
                          ctrlCelular: _ctrlCelular,
                          ctrlCorreo: _ctrlCorreo,
                          paises: paises,
                          paisCelular: paisCelular,
                          onPaisCelularChanged: (p) {
                            setState(() => _paisCelular = p);
                            _sincronizarCubit();
                          },
                          tipoDocInicialId: _tipoDocId.isNotEmpty
                              ? _tipoDocId
                              : null,
                          nacionalidadInicialId: _nacionalidadId.isNotEmpty
                              ? _nacionalidadId
                              : null,
                          sexoInicialId: _sexoId.isNotEmpty ? _sexoId : null,
                          onTipoDocChanged: (item) {
                            setState(() {
                              _tipoDocId = item?.id ?? '';
                              _tipoDocLabel = item?.abreviatura ?? '';
                            });
                            _sincronizarCubit();
                          },
                          onNacionalidadChanged: (item) {
                            setState(() {
                              _nacionalidadId = item?.id ?? '';
                              _nacionalidadLabel = item?.nombre ?? '';
                            });
                            _sincronizarCubit();
                          },
                          onSexoChanged: (item) {
                            setState(() => _sexoId = item?.id ?? '');
                            _sincronizarCubit();
                          },
                          onCargoChanged: _sincronizarCubit,
                          onBuscarDocumento: _buscarDocumentoSolicitante,
                        ),
                        if (tipoPersona == 'juridica') ...[
                          const SizedBox(height: AppSpacing.sm),

                          // ── Información comercial (solo jurídica) ──────────
                          SeccionInfoComercial(
                            habilitado: widget.modoEdicion,
                            ctrlRuc: _ctrlRuc,
                            ctrlRazonSocial: _ctrlRazonSocial,
                            onBuscarRuc: _buscarRucComercial,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.sm),

                        // ── Switches ───────────────────────────────────────
                        SeccionSwitches(
                          solicitanteParticipante: _solicitanteParticipante,
                          facturarAlSolicitante: _facturarAlSolicitante,
                          onSolicitanteChanged:
                              _onSolicitanteParticipanteChanged,
                          onFacturarChanged: (v) =>
                              _onFacturarAlSolicitanteChanged(v, paisCelular),
                          habilitado: widget.modoEdicion,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Botones de acción fijos al pie ──────────────────────────
              // En modo solo-ver (modoEdicion == false) solo se muestra
              // "Siguiente", sin validar ni guardar — es un recorrido de
              // lectura, no una captura de datos. En modo edición ya no hay
              // botón "Guardar" aparte — "Siguiente" valida y guarda
              // (borrador) antes de avanzar, ver _onContinuar.
              BotonesPasoSolicitante(
                modoEdicion: widget.modoEdicion,
                guardando: _guardando,
                onCancelar: _confirmarCancelar,
                onContinuar: () => _onContinuar(paisCelular),
              ),
            ],
          ),
          if (_buscandoDocSolicitante || _buscandoRuc)
            const AppLoadingOverlay(message: 'Buscando datos del documento...'),
          SolicitudProgresoOverlay(progreso: _progreso),
        ],
      ),
    );
  }
}
