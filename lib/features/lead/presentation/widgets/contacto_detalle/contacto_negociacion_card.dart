// lib/features/lead/presentation/widgets/contacto_detalle/contacto_negociacion_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoNegociacionCard extends StatelessWidget {
  final Lead lead;

  const ContactoNegociacionCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorEstado = AppIconsSocial.colorEstado(lead.idEstado);

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
                          AppIconsSocial.widgetCanal(
                            lead.idCanal,
                            size: AppSizing.iconXs,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              lead.evento.isNotEmpty ? lead.evento : lead.canal,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: AppTextStyles.weightSemiBold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            lead.fechaHora.formatSinHoy(),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Fila: chip estado + monto
                      Row(
                        children: [
                          AppIconsSocial.chipEstado(
                            lead.idEstado,
                            label: lead.estado,
                          ),
                          const Spacer(),
                          // TODO: mostrar campanita de notificaciones (lead.notificaciones)
                          // if (lead.notificaciones > 0)
                          //   Container(
                          //     padding: EdgeInsets.symmetric(
                          //       horizontal: AppSpacing.xs,
                          //       vertical: AppSpacing.xxs,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: AppColors.error,
                          //       borderRadius: BorderRadius.circular(AppSizing.radiusCircular),
                          //     ),
                          //     child: Icon(AppIcons.notification, size: AppSizing.iconSm, color: AppColors.textOnDark),
                          //   ),
                          if (lead.monto > 0)
                            Text(
                              _formatMonto(lead.monto),
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
