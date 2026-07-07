// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';

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
  // 'juridica' | 'natural'
  String _tipoPersona = 'juridica';

  // Canales seleccionados (multi-select)
  final Set<String> _canalesSeleccionados = {};

  // Switches — opciones del solicitante
  bool _solicitanteParticipante = false;
  bool _facturarAlSolicitante = false;

  // Labels/ids de combos capturados desde _SeccionDatosSolicitante
  String _tipoDocLabel = '';
  String _nacionalidadId = '';
  String _sexoId = '';
  String _campanaLabel = '';
  String _eventoLabel = '';

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
      _ctrlCorreo.text.trim().isNotEmpty &&
      _campanaLabel.isNotEmpty &&
      _eventoLabel.isNotEmpty;

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
    final resultado = await FilePicker.platform.pickFiles(type: FileType.any);
    final archivo = resultado?.files.single;
    if (archivo == null) return;
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
                  // ── N° de solicitud + Toggle tipo persona ──────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: _CampoNumeroSolicitud(
                          numero: widget.solicitud.idSolicitud.toString(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      SolicitudToggleTipoPersona(
                        valor: _tipoPersona,
                        habilitado: widget.modoEdicion,
                        onChanged: (v) => setState(() => _tipoPersona = v),
                      ),
                    ],
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
                    seleccionados: _canalesSeleccionados,
                    habilitado: widget.modoEdicion,
                    onToggle: (canal) {
                      if (!widget.modoEdicion) return;
                      setState(() {
                        if (_canalesSeleccionados.contains(canal)) {
                          _canalesSeleccionados.remove(canal);
                        } else {
                          _canalesSeleccionados.add(canal);
                        }
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
                    onTipoDocLabelChanged: (v) =>
                        setState(() => _tipoDocLabel = v),
                    onNacionalidadChanged: (v) =>
                        setState(() => _nacionalidadId = v),
                    onSexoChanged: (v) => setState(() => _sexoId = v),
                    onCampanaChanged: (v) => setState(() => _campanaLabel = v),
                    onEventoChanged: (v) => setState(() => _eventoLabel = v),
                  ),
                  if (_tipoPersona == 'juridica') ...[
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
                Expanded(child: SolicitudBotonBorrador(onPressed: () {})),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: SolicitudBotonContinuar(
                    onPressed: !_formCompleto
                        ? null
                        : () {
                            context
                                .read<SolicitudFormCubit>()
                                .guardarSolicitante(
                                  DatosSolicitante(
                                    tipoPersona: _tipoPersona,
                                    tipoDocLabel: _tipoDocLabel,
                                    numDoc: _ctrlNumDoc.text,
                                    nombres: _ctrlNombres.text,
                                    apellidoPaterno: _ctrlApellidoPaterno.text,
                                    apellidoMaterno: _ctrlApellidoMaterno.text,
                                    cargo: _ctrlCargo.text,
                                    celular: _ctrlCelular.text,
                                    correo: _ctrlCorreo.text,
                                    campana: _campanaLabel,
                                    evento: _eventoLabel,
                                    canales: _canalesSeleccionados.toList(),
                                    ruc: _ctrlRuc.text,
                                    razonSocial: _ctrlRazonSocial.text,
                                    solicitanteEsParticipante:
                                        _solicitanteParticipante,
                                    facturarAlSolicitante:
                                        _facturarAlSolicitante,
                                  ),
                                );
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

    return OutlinedButton.icon(
      onPressed: habilitado ? (tieneArchivo ? onQuitar : onAdjuntar) : null,
      icon: Icon(
        tieneArchivo ? AppIcons.checkCircleFilled : Icons.attach_file_rounded,
        size: AppSizing.iconActionSm,
      ),
      label: Text(
        tieneArchivo ? archivo!.name : label,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: tieneArchivo ? AppColors.success : AppColors.primary,
        side: BorderSide(
          color: tieneArchivo ? AppColors.success : AppColors.primary,
        ),
        minimumSize: const Size.fromHeight(AppSizing.buttonHeightSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        ),
        textStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: AppTextStyles.weightMedium,
        ),
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
              child: SolicitudTextField(
                label: 'RUC',
                hint: 'Ingrese el RUC',
                controller: ctrlRuc,
                keyboardType: TextInputType.number,
                enabled: habilitado,
                maxLength: 11,
                digitsOnly: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
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
  final ValueChanged<String>? onTipoDocLabelChanged;
  final ValueChanged<String>? onNacionalidadChanged;
  final ValueChanged<String>? onSexoChanged;
  final ValueChanged<String>? onCampanaChanged;
  final ValueChanged<String>? onEventoChanged;

  const _SeccionDatosSolicitante({
    required this.habilitado,
    required this.ctrlNumDoc,
    required this.ctrlNombres,
    required this.ctrlApellidoPaterno,
    required this.ctrlApellidoMaterno,
    required this.ctrlCargo,
    required this.ctrlCelular,
    required this.ctrlCorreo,
    this.onTipoDocLabelChanged,
    this.onNacionalidadChanged,
    this.onSexoChanged,
    this.onCampanaChanged,
    this.onEventoChanged,
  });

  @override
  State<_SeccionDatosSolicitante> createState() =>
      _SeccionDatosSolicitanteState();
}

class _SeccionDatosSolicitanteState extends State<_SeccionDatosSolicitante> {
  String? _tipoDocId;

  // Límite de caracteres y tipo de teclado según tipo de documento
  static const _maxLengthPorTipo = {
    '01': 8, // DNI
    '02': 12, // Pasaporte
    '03': 12, // Carnet de extranjería
    '04': 11, // RUC como doc de persona
  };
  static const _soloDigitosPorTipo = {
    '01': true,
    '02': false,
    '03': false,
    '04': true,
  };

  static const _tiposDoc = [
    '01¦DNI',
    '02¦Pasaporte',
    '03¦Carnet de extranjería',
    '04¦RUC',
  ];
  static const _nacionalidades = ['01¦PERUANO/A', '02¦EXTRANJERO/A'];
  static const _sexos = ['M¦Masculino', 'F¦Femenino', 'PD¦Por definir'];
  static const _campanas = ['01¦SEPTIEMBRE 2026', '02¦OCTUBRE 2026'];
  static const _eventos = ['01¦EXPOGESTIÓN 2026', '02¦OTRO EVENTO'];

  @override
  Widget build(BuildContext context) {
    final maxLenDoc = _tipoDocId != null ? _maxLengthPorTipo[_tipoDocId] : null;
    final soloDigitos = _soloDigitosPorTipo[_tipoDocId] ?? false;
    final teclado = soloDigitos ? TextInputType.number : TextInputType.text;

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
              child: SolicitudComboField(
                label: 'Tipo documento *',
                data: _tiposDoc,
                enabled: widget.habilitado,
                onChanged: (item) {
                  setState(() {
                    _tipoDocId = item?.id;
                    widget.ctrlNumDoc.clear();
                  });
                  widget.onTipoDocLabelChanged?.call(item?.descripcion ?? '');
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Número documento *',
                controller: widget.ctrlNumDoc,
                keyboardType: teclado,
                enabled: widget.habilitado,
                maxLength: maxLenDoc,
                digitsOnly: soloDigitos,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 2: Nacionalidad + Sexo
        Row(
          children: [
            Expanded(
              child: SolicitudComboField(
                label: 'Nacionalidad *',
                data: _nacionalidades,
                enabled: widget.habilitado,
                onChanged: (item) =>
                    widget.onNacionalidadChanged?.call(item?.id ?? ''),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudComboField(
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
        SolicitudTextField(
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
              child: SolicitudTextField(
                label: 'Apellido paterno *',
                controller: widget.ctrlApellidoPaterno,
                enabled: widget.habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
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
        SolicitudTextField(
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
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Correo *',
                controller: widget.ctrlCorreo,
                keyboardType: TextInputType.emailAddress,
                enabled: widget.habilitado,
                isUpperCase: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 5: Campaña + Evento
        Row(
          children: [
            Expanded(
              child: SolicitudComboField(
                label: 'Campaña *',
                data: _campanas,
                enabled: widget.habilitado,
                onChanged: (item) =>
                    widget.onCampanaChanged?.call(item?.descripcion ?? ''),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudComboField(
                label: 'Evento *',
                data: _eventos,
                enabled: widget.habilitado,
                onChanged: (item) =>
                    widget.onEventoChanged?.call(item?.descripcion ?? ''),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Campo N° de solicitud ─────────────────────────────────────────────────────

class _CampoNumeroSolicitud extends StatelessWidget {
  final String numero;

  const _CampoNumeroSolicitud({required this.numero});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'N° de solicitud',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: AppSizing.buttonHeightSmall,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceLightVariant,
            borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            numero,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: AppTextStyles.weightMedium,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Chips de canales ──────────────────────────────────────────────────────────

class _ChipsCanales extends StatelessWidget {
  final Set<String> seleccionados;
  final bool habilitado;
  final ValueChanged<String> onToggle;

  const _ChipsCanales({
    required this.seleccionados,
    required this.habilitado,
    required this.onToggle,
  });

  static const _canales = [
    (
      id: 'facebook',
      label: 'Facebook',
      asset: AppImages.iconFacebook,
      icon: Icons.facebook_rounded,
    ),
    (
      id: 'linkedin',
      label: 'LinkedIn',
      asset: AppImages.iconLinkedin,
      icon: Icons.work_outline_rounded,
    ),
    (
      id: 'instagram',
      label: 'Instagram',
      asset: AppImages.iconInstagram,
      icon: Icons.camera_alt_outlined,
    ),
    (
      id: 'logistica',
      label: 'Logística',
      asset: AppImages.iconLogistica,
      icon: Icons.inventory_2_outlined,
    ),
    (
      id: 'logistica360',
      label: 'Logística 360',
      asset: '',
      icon: Icons.cached_rounded,
    ),
    (id: 'otros', label: 'Otros', asset: '', icon: Icons.more_horiz_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _canales.map((canal) {
        final activo = seleccionados.contains(canal.id);
        final colorTexto = activo
            ? AppColors.primary
            : (habilitado ? AppColors.textSecondary : AppColors.textDisabled);

        return GestureDetector(
          onTap: () => onToggle(canal.id),
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
                width: activo ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (canal.asset.isNotEmpty)
                  Image.asset(
                    canal.asset,
                    width: AppSizing.iconActionSm,
                    height: AppSizing.iconActionSm,
                  )
                else
                  Icon(
                    canal.icon,
                    size: AppSizing.iconActionSm,
                    color: colorTexto,
                  ),
                const SizedBox(width: AppSpacing.sm2),
                Text(
                  canal.label,
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
