// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_secciones.dart
//
// Secciones auxiliares de SolicitudCompletarView (paso 1): tooltip
// informativo, canal del evento, switches del solicitante, información
// comercial (RUC) y botones de pie.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

// ── Sección Canal del evento ("¿Cómo se enteró?") ────────────────────────────

class SeccionCanalEvento extends StatelessWidget {
  final List<CanalExpoItem> canales;
  final CanalExpoItem? seleccionado;
  final bool habilitado;
  final ValueChanged<CanalExpoItem> onSeleccionar;
  final TextEditingController ctrlDetalle;

  const SeccionCanalEvento({
    super.key,
    required this.canales,
    required this.seleccionado,
    required this.habilitado,
    required this.onSeleccionar,
    required this.ctrlDetalle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          seleccionado: seleccionado,
          habilitado: habilitado,
          onSeleccionar: onSeleccionar,
        ),
        if (seleccionado?.esDetallado == true) ...[
          const SizedBox(height: AppSpacing.xs),
          CustomTextField(
            label: '¿Desde dónde se enteró? *',
            hint: 'Ej: Feria, recomendación, etc.',
            controller: ctrlDetalle,
            enabled: habilitado,
            textCapitalization: TextCapitalization.sentences,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Requerido' : null,
          ),
        ],
      ],
    );
  }
}

// ── Botones de pie del paso 1 (Cancelar/Siguiente o Continuar) ──────────────

class BotonesPasoSolicitante extends StatelessWidget {
  final bool modoEdicion;
  final bool guardando;
  final VoidCallback onCancelar;
  final VoidCallback onContinuar;

  const BotonesPasoSolicitante({
    super.key,
    required this.modoEdicion,
    required this.guardando,
    required this.onCancelar,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: modoEdicion
          ? Row(
              children: [
                Expanded(
                  child: CustomSecondaryButton(
                    text: 'Cancelar',
                    backgroundColor: AppColors.brandRaspberryAccessible,
                    onPressed: onCancelar,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: CustomPrimaryButton(
                    text: 'Siguiente →',
                    isLoading: guardando,
                    onPressed: onContinuar,
                  ),
                ),
              ],
            )
          : CustomPrimaryButton(text: 'Continuar →', onPressed: onContinuar),
    );
  }
}

// ── Tooltip — 3 partes de la solicitud ───────────────────────────────────────

class TooltipPartesSolicitud extends StatelessWidget {
  const TooltipPartesSolicitud({super.key});

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

class SeccionSwitches extends StatelessWidget {
  final bool solicitanteParticipante;
  final bool facturarAlSolicitante;
  final ValueChanged<bool> onSolicitanteChanged;
  final ValueChanged<bool> onFacturarChanged;
  final bool habilitado;

  const SeccionSwitches({
    super.key,
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
        ItemSwitch(
          icono: AppIcons.user,
          colorIcono: AppColors.brandForest,
          colorFondo: AppColors.brandForest.withValues(alpha: 0.12),
          label: 'El solicitante será participante',
          valor: solicitanteParticipante,
          habilitado: habilitado,
          onChanged: onSolicitanteChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        ItemSwitch(
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

class ItemSwitch extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color colorFondo;
  final String label;
  final bool valor;
  final bool habilitado;
  final ValueChanged<bool> onChanged;

  const ItemSwitch({
    super.key,
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

class SeccionInfoComercial extends StatefulWidget {
  final bool habilitado;
  final TextEditingController ctrlRuc;
  final TextEditingController ctrlRazonSocial;
  // Autocompletado de Razón Social por RUC (Clientes/BuscarDocumento) — se
  // dispara al perder foco o al presionar el check del teclado. El indicador
  // de carga es un overlay de pantalla completa que arma el padre
  // (SolicitudCompletarView), no algo local a este campo.
  final VoidCallback? onBuscarRuc;

  const SeccionInfoComercial({
    super.key,
    required this.habilitado,
    required this.ctrlRuc,
    required this.ctrlRazonSocial,
    this.onBuscarRuc,
  });

  @override
  State<SeccionInfoComercial> createState() => _SeccionInfoComercialState();
}

class _SeccionInfoComercialState extends State<SeccionInfoComercial> {
  late final FocusNode _rucFocus;

  @override
  void initState() {
    super.initState();
    _rucFocus = FocusNode()..addListener(_onRucFocusChange);
  }

  void _onRucFocusChange() {
    if (_rucFocus.hasFocus) return; // solo al perder el foco
    widget.onBuscarRuc?.call();
  }

  @override
  void dispose() {
    _rucFocus.removeListener(_onRucFocusChange);
    _rucFocus.dispose();
    super.dispose();
  }

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
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // RUC + Razón social — obligatorios: esta sección solo se muestra
        // con tipo de persona Jurídica (ver solicitud_completar_view.dart),
        // con Natural no se renderiza y no aplica ninguna validación.
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'RUC *',
                hint: 'Ingrese el RUC',
                controller: widget.ctrlRuc,
                focusNode: _rucFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => widget.onBuscarRuc?.call(),
                enabled: widget.habilitado,
                maxLength: 11,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Requerido'
                    : null,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: CustomTextField(
                label: 'Razón social *',
                hint: 'Ingrese la razón social',
                controller: widget.ctrlRazonSocial,
                enabled: widget.habilitado,
                isUpperCase: true,
                textCapitalization: TextCapitalization.words,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Requerido'
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
