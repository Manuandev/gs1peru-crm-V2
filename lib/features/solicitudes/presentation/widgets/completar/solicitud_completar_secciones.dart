// lib/features/solicitudes/presentation/widgets/completar/solicitud_completar_secciones.dart
//
// Secciones auxiliares de SolicitudCompletarView (paso 1): tooltip
// informativo, switches del solicitante e información comercial (RUC).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';

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
