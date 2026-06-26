// lib/features/lead/presentation/widgets/contacto_detalle/contacto_negociacion_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoNegociacionCard extends StatelessWidget {
  final NegociacionLead negociacion;

  const ContactoNegociacionCard({super.key, required this.negociacion});

  @override
  Widget build(BuildContext context) {
    final colorEstado = AppSocialUtils.colorEstado(negociacion.idEstado);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizing.radiusSm),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Borde izquierdo de color del estado
              Container(
                width: AppSizing.cardBorderEstadoAncho,
                color: colorEstado,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fila: canal + nombre evento + fecha
                      Row(
                        children: [
                          AppSocialUtils.widgetCanal(
                            negociacion.idCanal,
                            size: AppSizing.iconXs,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              negociacion.nombreOportunidad.isNotEmpty
                                  ? negociacion.nombreOportunidad
                                  : negociacion.descripcionCanal,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: AppTextStyles.weightSemiBold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            negociacion.fechaHora.formatSinHoy(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          AppSocialUtils.chipEstado(
                            negociacion.idEstado,
                            label: negociacion.descripcionEstado,
                          ),
                          const Spacer(),
                          if (negociacion.precioBase > 0)
                            Text(
                              _formatMonto(negociacion.precioBase),
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: AppTextStyles.weightSemiBold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMonto(double monto) =>
      'S/ ${monto.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '')}';
}
