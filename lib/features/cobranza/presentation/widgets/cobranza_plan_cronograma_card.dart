// lib/features/cobranza/presentation/widgets/cobranza_plan_cronograma_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Tabla de cuotas del plan de crédito con encabezado y conteo de filas.
class CobranzaPlanCronogramaCard extends StatelessWidget {
  final CobranzaPlanState state;
  const CobranzaPlanCronogramaCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final cuotas = state.cuotas;

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
          // ── Encabezado de tabla ──────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.06),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizing.radiusMd),
                topRight: Radius.circular(AppSizing.radiusMd),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: AppSizing.avatarSm,
                  child: Text(
                    'N°',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Vencimiento',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ),
                Text(
                  'Monto',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
                const SizedBox(width: AppSizing.iconSm),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          // ── Filas de cuotas ──────────────────────────────────
          if (cuotas.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Sin cuotas agregadas. Configura y presiona Vista previa.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            ...cuotas.map((c) => _FilaCuota(cuota: c)),
          // ── Conteo de filas ──────────────────────────────────
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Elementos mostrados: ${cuotas.length} registro(s)',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Total: S/ ${state.totalCuotas.toStringAsFixed(2)}',
                  style: AppTextStyles.labelMedium.copyWith(
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

// ── Fila individual del cronograma ────────────────────────────────────────────

class _FilaCuota extends StatelessWidget {
  final CuotaPlan cuota;
  const _FilaCuota({required this.cuota});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Círculo numerado
              Container(
                width: AppSizing.avatarSm,
                height: AppSizing.avatarSm,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryWithOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    '${cuota.numeroCuota}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTextStyles.weightBold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Fecha de vencimiento
              Expanded(
                child: Text(
                  cuota.fechaVencimiento,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Monto
              Text(
                'S/ ${cuota.monto.toStringAsFixed(2)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: AppTextStyles.weightMedium,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                AppIcons.forward,
                size: AppSizing.iconSm,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
        Divider(height: 1, thickness: 1, color: AppColors.divider),
      ],
    );
  }
}
