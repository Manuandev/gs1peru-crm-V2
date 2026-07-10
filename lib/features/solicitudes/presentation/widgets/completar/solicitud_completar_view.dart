// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_chips_canales.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_completar_adjuntos.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_completar_secciones.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_completar_datos_solicitante.dart';

class SolicitudCompletarView extends StatefulWidget {
  final Solicitud solicitud;
  final bool modoEdicion;

  const SolicitudCompletarView({
    super.key,
    required this.solicitud,
    required this.modoEdicion,
  });

  @override
  State<SolicitudCompletarView> createState() => _SolicitudCompletarViewState();
}

class _SolicitudCompletarViewState extends State<SolicitudCompletarView> {
  // Canal seleccionado (single-select) — catálogo real vía CatalogsBloc
  CanalItem? _canalSeleccionado;

  // País del código telefónico del celular — catálogo real vía CatalogsBloc
  PaisItem? _paisCelular;

  // Switches — opciones del solicitante
  bool _solicitanteParticipante = false;
  bool _facturarAlSolicitante = false;

  // Labels/ids de combos capturados desde SeccionDatosSolicitante
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

  // Archivos adjuntos — voucher y orden de compra
  PlatformFile? _archivoVoucher;
  PlatformFile? _archivoOC;

  /// Campos obligatorios (marcados con *) del paso 1. Los opcionales
  /// (apellido materno, RUC/razón social, canales) no se exigen.
  bool get _formCompleto =>
      _tipoDocLabel.isNotEmpty &&
      _ctrlNumDoc.text.trim().isNotEmpty &&
      _nacionalidadId.isNotEmpty &&
      _sexoId.isNotEmpty &&
      _ctrlNombres.text.trim().isNotEmpty &&
      _ctrlApellidoPaterno.text.trim().isNotEmpty &&
      _ctrlCargo.text.trim().isNotEmpty &&
      _ctrlCelular.text.trim().isNotEmpty &&
      _ctrlCorreo.text.emailValidator == null;

  void _onCampoTexto() => setState(() {});

  @override
  void initState() {
    super.initState();
    for (final ctrl in [
      _ctrlNumDoc,
      _ctrlNombres,
      _ctrlApellidoPaterno,
      _ctrlCargo,
      _ctrlCelular,
      _ctrlCorreo,
    ]) {
      ctrl.addListener(_onCampoTexto);
    }
  }

  Future<void> _adjuntarArchivo(bool esVoucher) async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final archivo = resultado?.files.single;
    if (archivo == null) return;

    final extension = archivo.extension?.toLowerCase();
    if (extension != 'pdf') {
      if (mounted) {
        AppSnackBar.error(context, 'Solo se permiten archivos PDF');
      }
      return;
    }

    setState(() {
      if (esVoucher) {
        _archivoVoucher = archivo;
      } else {
        _archivoOC = archivo;
      }
    });
  }

  void _quitarArchivo(bool esVoucher) {
    setState(() {
      if (esVoucher) {
        _archivoVoucher = null;
      } else {
        _archivoOC = null;
      }
    });
  }

  Future<void> _confirmarCancelar() async {
    final confirmado = await context.showConfirmDialog(
      title: 'Cancelar solicitud',
      message: '¿Desea cancelar el proceso de solicitud?',
      confirmText: 'Sí, cancelar',
      cancelText: 'No',
    );
    if (confirmado && mounted) context.goBack();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tipoPersona = context.watch<SolicitudFormCubit>().state.tipoPersona;
    final catalogState = context.watch<CatalogsBloc>().state;
    final canales = catalogState is CatalogsLoaded
        ? catalogState.canales
        : const <CanalItem>[];
    final paises = catalogState is CatalogsLoaded
        ? catalogState.paises
        : const <PaisItem>[];
    final paisCelular =
        _paisCelular ??
        (paises.isEmpty
            ? null
            : paises.where((p) => p.codigoTelefono == '51').firstOrNull ??
                  paises.first);

    return BasePage(
      onPop: () => context.goBack(),
      drawerSide: DrawerSide.none,
      bodyPadding: EdgeInsets.zero,
      title: 'Solicitud de inscripción',
      appBarLeadingButtons: [
        IconButton(
          onPressed: () => context.goBack(),
          icon: Icon(
            AppIcons.back,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
      appBarTrailingButtons: [const SolicitudBadgePaso(paso: 1)],
      body: Column(
        children: [
          const SolicitudPasosIndicador(pasoActual: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
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
                  Text(
                    '¿Cómo se enteró del evento?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightMedium,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ChipsCanales(
                    canales: canales,
                    seleccionado: _canalSeleccionado,
                    habilitado: widget.modoEdicion,
                    onSeleccionar: (canal) {
                      if (!widget.modoEdicion) return;
                      setState(() {
                        _canalSeleccionado = _canalSeleccionado?.id == canal.id
                            ? null
                            : canal;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // ── Botones de adjuntos ────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BotonAdjuntar(
                          label: 'Adjuntar voucher',
                          archivo: _archivoVoucher,
                          habilitado: widget.modoEdicion,
                          onAdjuntar: () => _adjuntarArchivo(true),
                          onQuitar: () => _quitarArchivo(true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: BotonAdjuntar(
                          label: 'Adjuntar O/C',
                          archivo: _archivoOC,
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
                    onPaisCelularChanged: (p) =>
                        setState(() => _paisCelular = p),
                    onTipoDocLabelChanged: (v) =>
                        setState(() => _tipoDocLabel = v),
                    onNacionalidadChanged: (item) => setState(() {
                      _nacionalidadId = item?.id ?? '';
                      _nacionalidadLabel = item?.nombre ?? '';
                    }),
                    onSexoChanged: (v) => setState(() => _sexoId = v),
                  ),
                  if (tipoPersona == 'juridica') ...[
                    const SizedBox(height: AppSpacing.sm),

                    // ── Información comercial (solo jurídica) ──────────
                    SeccionInfoComercial(
                      habilitado: widget.modoEdicion,
                      ctrlRuc: _ctrlRuc,
                      ctrlRazonSocial: _ctrlRazonSocial,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),

                  // ── Switches ───────────────────────────────────────
                  SeccionSwitches(
                    solicitanteParticipante: _solicitanteParticipante,
                    facturarAlSolicitante: _facturarAlSolicitante,
                    onSolicitanteChanged: (v) =>
                        setState(() => _solicitanteParticipante = v),
                    onFacturarChanged: (v) =>
                        setState(() => _facturarAlSolicitante = v),
                    habilitado: widget.modoEdicion,
                  ),
                ],
              ),
            ),
          ),

          // ── Botones de acción fijos al pie ──────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomSecondaryButton(
                    text: 'Cancelar',
                    backgroundColor: AppColors.brandRaspberryAccessible,
                    onPressed: _confirmarCancelar,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: CustomSecondaryButton(
                    text: 'Guardar',
                    icon: AppIcons.save,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: CustomPrimaryButton(
                    text: 'Continuar →',
                    onPressed: !_formCompleto
                        ? null
                        : () {
                            final datos = DatosSolicitante(
                              tipoDocLabel: _tipoDocLabel,
                              numDoc: _ctrlNumDoc.text,
                              nacionalidad: _nacionalidadLabel,
                              nombres: _ctrlNombres.text,
                              apellidoPaterno: _ctrlApellidoPaterno.text,
                              apellidoMaterno: _ctrlApellidoMaterno.text,
                              cargo: _ctrlCargo.text,
                              celular: _ctrlCelular.text,
                              celularCodigoTelefono:
                                  paisCelular?.codigoTelefono ?? '',
                              correo: _ctrlCorreo.text,
                              canalId: _canalSeleccionado?.id,
                              canalNombre: _canalSeleccionado?.nombre ?? '',
                              ruc: _ctrlRuc.text,
                              razonSocial: _ctrlRazonSocial.text,
                              solicitanteEsParticipante:
                                  _solicitanteParticipante,
                              facturarAlSolicitante: _facturarAlSolicitante,
                            );
                            context
                                .read<SolicitudFormCubit>()
                                .guardarSolicitante(datos);
                            context
                                .read<ParticipantesCubit>()
                                .sincronizarSolicitante(datos);
                            context.goToFichaParticipantesSolicitud(
                              solicitud: widget.solicitud,
                              modoEdicion: widget.modoEdicion,
                              formCubit: context.read<SolicitudFormCubit>(),
                              participantesCubit: context
                                  .read<ParticipantesCubit>(),
                            );
                          },
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
