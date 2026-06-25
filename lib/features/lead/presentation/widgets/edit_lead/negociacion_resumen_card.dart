// lib/features/lead/presentation/widgets/edit_lead/negociacion_resumen_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

/// Resumen financiero de la negociación: subtotal, descuento y total.
/// Se muestra en la sección financiera del formulario de edición de lead.
class NegociacionResumenCard extends StatelessWidget {
  final double subtotal;
  final double descuento;
  final double costoFinal;

  const NegociacionResumenCard({
    super.key,
    required this.subtotal,
    required this.descuento,
    required this.costoFinal,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt         = NumberFormat('#,##0.00', 'es_PE');
    final montoDesc   = subtotal * (descuento / 100);

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
                      'S/ ${fmt.format(subtotal)}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
                if (descuento > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Descuento (${descuento.toStringAsFixed(0)}%)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      Text(
                        '- S/ ${fmt.format(montoDesc)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
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
                'S/ ${fmt.format(costoFinal)}',
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
