// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';

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

  // Labels/ids de combos capturados desde _SeccionDatosSolicitante
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
                  _ChipsCanales(
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
                        child: _BotonAdjuntar(
                          label: 'Adjuntar voucher',
                          archivo: _archivoVoucher,
                          habilitado: widget.modoEdicion,
                          onAdjuntar: () => _adjuntarArchivo(true),
                          onQuitar: () => _quitarArchivo(true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _BotonAdjuntar(
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
                  const _TooltipPartesSolicitud(),
                  const SizedBox(height: AppSpacing.sm),

                  // ── Datos del solicitante ──────────────────────────
                  _SeccionDatosSolicitante(
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
                    _SeccionInfoComercial(
                      habilitado: widget.modoEdicion,
                      ctrlRuc: _ctrlRuc,
                      ctrlRazonSocial: _ctrlRazonSocial,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),

                  // ── Switches ───────────────────────────────────────
                  _SeccionSwitches(
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

// ── Botón de adjuntar archivo (voucher / O-C) ─────────────────────────────────

class _BotonAdjuntar extends StatelessWidget {
  final String label;
  final PlatformFile? archivo;
  final bool habilitado;
  final VoidCallback onAdjuntar;
  final VoidCallback onQuitar;

  const _BotonAdjuntar({
    required this.label,
    required this.archivo,
    required this.habilitado,
    required this.onAdjuntar,
    required this.onQuitar,
  });

  @override
  Widget build(BuildContext context) {
    final tieneArchivo = archivo != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: (habilitado && !tieneArchivo) ? onAdjuntar : null,
          icon: const Icon(
            Icons.attach_file_rounded,
            size: AppSizing.iconActionSm,
          ),
          label: Text(label, overflow: TextOverflow.ellipsis),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size.fromHeight(AppSizing.buttonHeightSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            textStyle: AppTextStyles.labelMedium.copyWith(
              fontWeight: AppTextStyles.weightMedium,
            ),
          ),
        ),
        if (tieneArchivo) ...[
          const SizedBox(height: AppSpacing.xs),
          _TarjetaArchivoAdjunto(
            nombre: archivo!.name,
            onQuitar: habilitado ? onQuitar : null,
          ),
        ],
      ],
    );
  }
}

// ── Tarjeta de archivo adjunto (PDF) con opción de quitar ─────────────────────

class _TarjetaArchivoAdjunto extends StatelessWidget {
  final String nombre;
  final VoidCallback? onQuitar;

  const _TarjetaArchivoAdjunto({required this.nombre, required this.onQuitar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.pdf,
            color: AppColors.success,
            size: AppSizing.iconActionSm,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (onQuitar != null)
            GestureDetector(
              onTap: onQuitar,
              child: const Icon(
                AppIcons.close,
                size: AppSizing.iconSm,
                color: AppColors.error,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tooltip — 3 partes de la solicitud ───────────────────────────────────────

class _TooltipPartesSolicitud extends StatelessWidget {
  const _TooltipPartesSolicitud();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.ui2,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: AppSizing.iconActionSm,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm2),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                children: [
                  const TextSpan(
                    text: 'La solicitud se completa en 3 partes:\n',
                  ),
                  TextSpan(
                    text: 'solicitante',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: 'participantes',
                    style: TextStyle(
                      color: AppColors.brandForest,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                  const TextSpan(text: ' y '),
                  TextSpan(
                    text: 'facturación',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección Switches ─────────────────────────────────────────────────────────

class _SeccionSwitches extends StatelessWidget {
  final bool solicitanteParticipante;
  final bool facturarAlSolicitante;
  final ValueChanged<bool> onSolicitanteChanged;
  final ValueChanged<bool> onFacturarChanged;
  final bool habilitado;

  const _SeccionSwitches({
    required this.solicitanteParticipante,
    required this.facturarAlSolicitante,
    required this.onSolicitanteChanged,
    required this.onFacturarChanged,
    required this.habilitado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ItemSwitch(
          icono: AppIcons.user,
          colorIcono: AppColors.brandForest,
          colorFondo: AppColors.brandForest.withValues(alpha: 0.12),
          label: 'El solicitante será participante',
          valor: solicitanteParticipante,
          habilitado: habilitado,
          onChanged: onSolicitanteChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _ItemSwitch(
          icono: AppIcons.receipt,
          colorIcono: AppColors.secondary,
          colorFondo: AppColors.secondaryWithOpacity(0.12),
          label: 'Facturar al solicitante',
          valor: facturarAlSolicitante,
          habilitado: habilitado,
          onChanged: onFacturarChanged,
        ),
      ],
    );
  }
}

class _ItemSwitch extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String label;
  final bool valor;
  final bool habilitado;
  final ValueChanged<bool> onChanged;

  const _ItemSwitch({
    required this.icono,
    required this.colorIcono,
    required this.colorFondo,
    required this.label,
    required this.valor,
    required this.habilitado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppSizing.iconMd,
          height: AppSizing.iconMd,
          decoration: BoxDecoration(
            color: colorFondo,
            borderRadius: BorderRadius.circular(AppSizing.radiusXs),
          ),
          child: Icon(icono, color: colorIcono, size: AppSizing.iconSm),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Transform.scale(
          scale: 0.8,
          alignment: Alignment.centerRight,
          child: Switch(
            value: valor,
            onChanged: habilitado ? onChanged : null,
            thumbColor: WidgetStateProperty.all(AppColors.textOnDark),
            trackColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return AppColors.border;
            }),
            trackOutlineColor: WidgetStateProperty.all(AppColors.border),
          ),
        ),
      ],
    );
  }
}

// ── Sección Información comercial ────────────────────────────────────────────

class _SeccionInfoComercial extends StatelessWidget {
  final bool habilitado;
  final TextEditingController ctrlRuc;
  final TextEditingController ctrlRazonSocial;

  const _SeccionInfoComercial({
    required this.habilitado,
    required this.ctrlRuc,
    required this.ctrlRazonSocial,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.business_rounded,
              color: AppColors.primary,
              size: AppSizing.iconMd,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Información comercial',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '(opcional)',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: AppTextStyles.weightRegular,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // RUC + Razón social
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'RUC',
                hint: 'Ingrese el RUC',
                controller: ctrlRuc,
                keyboardType: TextInputType.number,
                enabled: habilitado,
                maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Razón social',
                hint: 'Ingrese la razón social',
                controller: ctrlRazonSocial,
                enabled: habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Sección Datos del solicitante ────────────────────────────────────────────

class _SeccionDatosSolicitante extends StatefulWidget {
  final bool habilitado;
  final TextEditingController ctrlNumDoc;
  final TextEditingController ctrlNombres;
  final TextEditingController ctrlApellidoPaterno;
  final TextEditingController ctrlApellidoMaterno;
  final TextEditingController ctrlCargo;
  final TextEditingController ctrlCelular;
  final TextEditingController ctrlCorreo;
  final List<PaisItem> paises;
  final PaisItem? paisCelular;
  final ValueChanged<PaisItem> onPaisCelularChanged;
  final ValueChanged<String>? onTipoDocLabelChanged;
  final ValueChanged<NacionalidadItem?>? onNacionalidadChanged;
  final ValueChanged<String>? onSexoChanged;

  const _SeccionDatosSolicitante({
    required this.habilitado,
    required this.ctrlNumDoc,
    required this.ctrlNombres,
    required this.ctrlApellidoPaterno,
    required this.ctrlApellidoMaterno,
    required this.ctrlCargo,
    required this.ctrlCelular,
    required this.ctrlCorreo,
    required this.paises,
    required this.paisCelular,
    required this.onPaisCelularChanged,
    this.onTipoDocLabelChanged,
    this.onNacionalidadChanged,
    this.onSexoChanged,
  });

  @override
  State<_SeccionDatosSolicitante> createState() =>
      _SeccionDatosSolicitanteState();
}

class _SeccionDatosSolicitanteState extends State<_SeccionDatosSolicitante> {
  String? _tipoDocId;

  // Límite de caracteres y tipo de teclado según tipo de documento —
  // códigos reales de SYSTABEXTER02 CODTABLA='F01' (catálogo real).
  static const _maxLengthPorTipo = {
    '1': 8, // DNI
    '4': 12, // Carnet de extranjería
    '6': 11, // RUC
    '7': 12, // Pasaporte
  };
  static const _soloDigitosPorTipo = {'1': true, '4': false, '6': true, '7': false};

  // Sexo no tiene catálogo de backend — se mantiene hardcodeado por ahora.
  static const _sexos = ['M¦Masculino', 'F¦Femenino', 'PD¦Por definir'];

  @override
  Widget build(BuildContext context) {
    final maxLenDoc = _tipoDocId != null ? _maxLengthPorTipo[_tipoDocId] : null;
    final soloDigitos = _soloDigitosPorTipo[_tipoDocId] ?? false;
    final teclado = soloDigitos ? TextInputType.number : TextInputType.text;

    final catalogState = context.watch<CatalogsBloc>().state;
    final tiposDocumento = catalogState is CatalogsLoaded
        ? catalogState.tiposDocumento
        : const <TipoDocumentoItem>[];
    final nacionalidades = catalogState is CatalogsLoaded
        ? catalogState.nacionalidades
        : const <NacionalidadItem>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: AppSizing.iconMd,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Datos del solicitante',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Fila 1: Tipo documento + Número documento
        Row(
          children: [
            Expanded(
              child: CustomComboField<TipoDocumentoItem>(
                label: 'Tipo documento *',
                data: tiposDocumento,
                enabled: widget.habilitado,
                onChanged: (item) {
                  setState(() {
                    _tipoDocId = item?.id;
                    widget.ctrlNumDoc.clear();
                  });
                  widget.onTipoDocLabelChanged?.call(item?.nombre ?? '');
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Número documento *',
                controller: widget.ctrlNumDoc,
                keyboardType: teclado,
                enabled: widget.habilitado,
                maxLength: maxLenDoc,
                inputFormatters: soloDigitos
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 2: Nacionalidad + Sexo
        Row(
          children: [
            Expanded(
              child: CustomComboField<NacionalidadItem>(
                label: 'Nacionalidad *',
                data: nacionalidades,
                enabled: widget.habilitado,
                onChanged: (item) => widget.onNacionalidadChanged?.call(item),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomComboSearchField(
                label: 'Sexo *',
                data: _sexos,
                enabled: widget.habilitado,
                onChanged: (item) => widget.onSexoChanged?.call(item?.id ?? ''),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Nombres
        CustomTextField(
          label: 'Nombres *',
          controller: widget.ctrlNombres,
          enabled: widget.habilitado,
          isUpperCase: true,
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 3: Apellido paterno + Apellido materno
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Apellido paterno *',
                controller: widget.ctrlApellidoPaterno,
                enabled: widget.habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Apellido materno',
                controller: widget.ctrlApellidoMaterno,
                enabled: widget.habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Cargo
        CustomTextField(
          label: 'Cargo *',
          controller: widget.ctrlCargo,
          enabled: widget.habilitado,
          isUpperCase: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 4: Celular + Correo
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SolicitudCampoCelular(
                controller: widget.ctrlCelular,
                habilitado: widget.habilitado,
                paises: widget.paises,
                paisSeleccionado: widget.paisCelular,
                onPaisChanged: widget.onPaisCelularChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Correo *',
                controller: widget.ctrlCorreo,
                keyboardType: TextInputType.emailAddress,
                enabled: widget.habilitado,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Chips de canales — catálogo real (CatalogsBloc), selección única ─────────

class _ChipsCanales extends StatelessWidget {
  final List<CanalItem> canales;
  final CanalItem? seleccionado;
  final bool habilitado;
  final ValueChanged<CanalItem> onSeleccionar;

  const _ChipsCanales({
    required this.canales,
    required this.seleccionado,
    required this.habilitado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    if (canales.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: canales.map((canal) {
        final activo = seleccionado?.id == canal.id;
        final colorTexto = activo
            ? AppColors.primary
            : (habilitado ? AppColors.textSecondary : AppColors.textDisabled);

        return GestureDetector(
          onTap: habilitado ? () => onSeleccionar(canal) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: activo
                  ? AppColors.primaryWithOpacity(0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
              border: Border.all(
                color: activo ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppSocialUtils.widgetCanalById(
                  canal.id,
                  size: AppSizing.iconActionSm,
                ),
                const SizedBox(width: AppSpacing.sm2),
                Text(
                  canal.nombre,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colorTexto,
                    fontWeight: activo
                        ? AppTextStyles.weightSemiBold
                        : AppTextStyles.weightRegular,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
