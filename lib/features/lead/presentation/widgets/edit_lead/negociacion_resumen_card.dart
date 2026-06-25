// lib/features/lead/presentation/widgets/edit_lead/negociacion_resumen_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

/// Resumen financiero de la negociación: subtotal, descuento y total.
/// Descuento es un monto absoluto (no porcentaje).
/// Se muestra siempre, incluso cuando los valores son cero.
class NegociacionResumenCard extends StatelessWidget {
  final double subtotal;
  /// Monto a descontar (absoluto, no porcentaje).
  final double montoDescuento;
  final double costoFinal;
  final String simbolo;

  const NegociacionResumenCard({
    super.key,
    required this.subtotal,
    required this.montoDescuento,
    required this.costoFinal,
    this.simbolo = 'S/',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt         = NumberFormat('#,##0.00', 'es_PE');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        AppColors.primaryWithOpacity(0.06),
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
        border:       Border.all(color: AppColors.primaryWithOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color:        colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Icon(
              AppIcons.receipt,
              color: AppColors.textOnDark,
              size:  AppSizing.iconMd,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resumen de la negociación',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: AppTextStyles.bodySmall),
                    Text(
                      '$simbolo ${fmt.format(subtotal)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Descuento',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: montoDescuento > 0 ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '- $simbolo ${fmt.format(montoDescuento)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: montoDescuento > 0 ? AppColors.error : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Total',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$simbolo ${fmt.format(costoFinal)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color:      colorScheme.primary,
                  fontWeight: AppTextStyles.weightBold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
