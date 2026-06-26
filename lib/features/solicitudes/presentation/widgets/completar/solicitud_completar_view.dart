// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_view.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_pasos_indicador.dart';
import 'package:app_crm/features/solicitudes/presentation/widgets/completar/solicitud_inputs.dart';

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
      appBarTrailingButtons: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.white(0.15),
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Text(
              'Paso 1 de 4',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightSemiBold,
              ),
            ),
          ),
        ),
      ],
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
                      _ToggleTipoPersona(
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
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.modoEdicion ? () {} : null,
                          icon: const Icon(
                            Icons.attach_file_rounded,
                            size: AppSizing.iconActionSm,
                          ),
                          label: const Text('Adjuntar voucher'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            minimumSize: const Size.fromHeight(
                              AppSizing.buttonHeightSmall,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizing.radiusSm,
                              ),
                            ),
                            textStyle: AppTextStyles.labelMedium.copyWith(
                              fontWeight: AppTextStyles.weightMedium,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.modoEdicion ? () {} : null,
                          icon: const Icon(
                            Icons.attach_file_rounded,
                            size: AppSizing.iconActionSm,
                          ),
                          label: const Text('Adjuntar O/C'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            minimumSize: const Size.fromHeight(
                              AppSizing.buttonHeightSmall,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizing.radiusSm,
                              ),
                            ),
                            textStyle: AppTextStyles.labelMedium.copyWith(
                              fontWeight: AppTextStyles.weightMedium,
                            ),
                          ),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      AppIcons.save,
                      size: AppSizing.iconActionSm,
                    ),
                    label: const Text('Guardar borrador'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.secondary),
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                      textStyle: AppTextStyles.labelMedium.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.goToFichaParticipantesSolicitud(
                      solicitud: widget.solicitud,
                      modoEdicion: widget.modoEdicion,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnDark,
                      minimumSize: const Size.fromHeight(
                        AppSizing.buttonHeightSmall,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
                      ),
                      textStyle: AppTextStyles.labelMedium.copyWith(
                        fontWeight: AppTextStyles.weightSemiBold,
                      ),
                    ),
                    child: const Text('Continuar →'),
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
          colorFondo: AppColors.brandForest.withOpacity(0.12),
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

class _SeccionDatosSolicitante extends StatelessWidget {
  final bool habilitado;
  final TextEditingController ctrlNumDoc;
  final TextEditingController ctrlNombres;
  final TextEditingController ctrlApellidoPaterno;
  final TextEditingController ctrlApellidoMaterno;
  final TextEditingController ctrlCargo;
  final TextEditingController ctrlCelular;
  final TextEditingController ctrlCorreo;

  const _SeccionDatosSolicitante({
    required this.habilitado,
    required this.ctrlNumDoc,
    required this.ctrlNombres,
    required this.ctrlApellidoPaterno,
    required this.ctrlApellidoMaterno,
    required this.ctrlCargo,
    required this.ctrlCelular,
    required this.ctrlCorreo,
  });

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
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Número documento *',
                controller: ctrlNumDoc,
                keyboardType: TextInputType.number,
                enabled: habilitado,
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
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudComboField(
                label: 'Sexo *',
                data: _sexos,
                enabled: habilitado,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),

        // Nombres
        SolicitudTextField(
          label: 'Nombres *',
          controller: ctrlNombres,
          enabled: habilitado,
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
                controller: ctrlApellidoPaterno,
                enabled: habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Apellido materno',
                controller: ctrlApellidoMaterno,
                enabled: habilitado,
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
          controller: ctrlCargo,
          enabled: habilitado,
          isUpperCase: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: AppSpacing.xs),

        // Fila 4: Celular + Correo
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _CampoCelular(
                controller: ctrlCelular,
                habilitado: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudTextField(
                label: 'Correo *',
                controller: ctrlCorreo,
                keyboardType: TextInputType.emailAddress,
                enabled: habilitado,
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
                enabled: habilitado,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SolicitudComboField(
                label: 'Evento *',
                data: _eventos,
                enabled: habilitado,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Campo celular con selector de prefijo ─────────────────────────────────────

class _CampoCelular extends StatelessWidget {
  final TextEditingController controller;
  final bool habilitado;

  const _CampoCelular({required this.controller, required this.habilitado});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Selector de prefijo telefónico
          GestureDetector(
            onTap: habilitado ? () {} : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              decoration: BoxDecoration(
                color: habilitado
                    ? AppColors.inputBackground
                    : AppColors.surfaceLightVariant,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🇵🇪',
                    style: TextStyle(fontSize: AppTextStyles.sizeMd),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '+51',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: AppTextStyles.weightMedium,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: AppSizing.iconSm,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: SolicitudTextField(
              label: 'Celular *',
              controller: controller,
              keyboardType: TextInputType.phone,
              enabled: habilitado,
            ),
          ),
        ],
      ),
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

// ── Toggle Jurídica / Natural (pill deslizante) ───────────────────────────────

class _ToggleTipoPersona extends StatelessWidget {
  final String valor;
  final bool habilitado;
  final ValueChanged<String> onChanged;

  const _ToggleTipoPersona({
    required this.valor,
    required this.habilitado,
    required this.onChanged,
  });

  static const _duracion = Duration(milliseconds: 250);
  static const _curva = Curves.easeInOut;
  // Ancho fijo por opción — evita ancho infinito en el Stack
  static const double _anchoPorOpcion = 82.0;

  @override
  Widget build(BuildContext context) {
    final esJuridica = valor == 'juridica';

    return SizedBox(
      height: AppSizing.buttonHeightSmall,
      width: _anchoPorOpcion * 2 + 6, // +6 = padding all(3) x2
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceLightVariant,
          borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
        ),
        child: Stack(
          children: [
            // ── Pill deslizante ───────────────────────────────
            AnimatedPositioned(
              duration: _duracion,
              curve: _curva,
              left: esJuridica ? 0 : _anchoPorOpcion,
              top: 0,
              bottom: 0,
              width: _anchoPorOpcion,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black(0.14),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),

            // ── Etiquetas (encima del pill) ───────────────────
            Row(
              children: [
                SizedBox(
                  width: _anchoPorOpcion,
                  child: GestureDetector(
                    onTap: habilitado ? () => onChanged('juridica') : null,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duracion,
                        curve: _curva,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: esJuridica
                              ? AppColors.textOnDark
                              : AppColors.textSecondary,
                          fontWeight: esJuridica
                              ? AppTextStyles.weightSemiBold
                              : AppTextStyles.weightRegular,
                        ),
                        child: const Text('Jurídica'),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _anchoPorOpcion,
                  child: GestureDetector(
                    onTap: habilitado ? () => onChanged('natural') : null,
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: _duracion,
                        curve: _curva,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: !esJuridica
                              ? AppColors.textOnDark
                              : AppColors.textSecondary,
                          fontWeight: !esJuridica
                              ? AppTextStyles.weightSemiBold
                              : AppTextStyles.weightRegular,
                        ),
                        child: const Text('Natural'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

