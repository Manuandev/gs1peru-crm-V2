// lib/features/cobranza/presentation/widgets/plan/cobranza_plan_resumen_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Card 2×2 con los totales del plan de crédito (imagen adjunta).
class CobranzaPlanResumenCard extends StatelessWidget {
  final CobranzaPlanState state;
  const CobranzaPlanResumenCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Fila superior ────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _Celda(
                    icono: AppIcons.file,
                    colorIcono: AppColors.primary,
                    fondoIcono: AppColors.primaryWithOpacity(0.08),
                    label: 'Importe comprobante',
                    valor: 'S/ ${state.montoTotal.toStringAsFixed(2)}',
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _Celda(
                    icono: AppIcons.creditCard,
                    colorIcono: AppColors.success,
                    fondoIcono: AppColors.successWithOpacity(0.08),
                    label: 'Importe a crédito',
                    valor: 'S/ ${state.importeCredito.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          // ── Fila inferior ────────────────────────────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _Celda(
                    icono: AppIcons.moneda,
                    colorIcono: AppColors.secondary,
                    fondoIcono: AppColors.secondaryWithOpacity(0.08),
                    label: 'Detracción (12%)',
                    valor: 'S/ ${state.detraccion.toStringAsFixed(2)}',
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: AppColors.divider,
                ),
                Expanded(
                  child: _Celda(
                    icono: AppIcons.calendar,
                    colorIcono: AppColors.purple,
                    fondoIcono: AppColors.purpleWithOpacity(0.08),
                    label: 'Cuotas',
                    valor: '${state.cuotas.length}',
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

// ── Celda individual del grid 2×2 ─────────────────────────────────────────────

class _Celda extends StatelessWidget {
  final IconData icono;
  final Color colorIcono;
  final Color fondoIcono;
  final String label;
  final String valor;

  const _Celda({
    required this.icono,
    required this.colorIcono,
    required this.fondoIcono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: AppSizing.avatarSm,
            height: AppSizing.avatarSm,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fondoIcono,
            ),
            child: Icon(icono, size: AppSizing.iconMd, color: colorIcono),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  valor,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: AppTextStyles.weightBold,
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
