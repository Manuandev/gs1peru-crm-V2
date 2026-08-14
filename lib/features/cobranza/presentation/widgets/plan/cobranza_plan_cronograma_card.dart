// lib/features/cobranza/presentation/widgets/plan/cobranza_plan_cronograma_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Tabla de cuotas del plan de crédito. Cada fila es tappable — selecciona
/// la cuota para editarla en CobranzaPlanConfigurarCard.
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
                  width: AppSizing.iconLg,
                  child: Text(
                    'N°',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ),
                SizedBox(
                  width: AppSizing.iconLg,
                  child: Text(
                    'Días',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ),
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
            ...cuotas.map(
              (c) => _FilaCuota(
                cuota: c,
                seleccionada: c.numeroCuota == state.formNumeroCuota,
              ),
            ),
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
                  'Total: ${NumberFormatUtils.formatMonto(state.totalCuotas)}',
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
  final bool seleccionada;
  const _FilaCuota({required this.cuota, required this.seleccionada});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () =>
              context.read<CobranzaPlanBloc>().add(CuotaSeleccionada(cuota)),
          child: Container(
            color: seleccionada
                ? AppColors.primaryWithOpacity(0.06)
                : AppColors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                // N° — número plano, sin fondo de avatar
                SizedBox(
                  width: AppSizing.iconLg,
                  child: Text(
                    '${cuota.numeroCuota}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: AppTextStyles.weightSemiBold,
                    ),
                  ),
                ),
                SizedBox(
                  width: AppSizing.iconLg,
                  child: Text(
                    '${diasDesdeHoy(cuota.fechaVencimiento)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
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
                  NumberFormatUtils.formatMonto(cuota.monto),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: AppColors.divider),
      ],
    );
  }
}
