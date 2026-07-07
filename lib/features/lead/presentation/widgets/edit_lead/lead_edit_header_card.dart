// lib/features/lead/presentation/widgets/edit_lead/lead_edit_header_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Card de encabezado del formulario de edición de lead.
/// Muestra avatar con iniciales, nombre completo, canal, estado y empresa.
class LeadEditHeaderCard extends StatelessWidget {
  final Negociacion lead;
  const LeadEditHeaderCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Nombre de contacto — no disponible en Negociacion; pendiente de
    // conectar con la fuente de Contacto de esta pantalla.
    const nombreCompleto = '';
    final avatarColor = nombreCompleto.avatarColor;
    final iniciales   = nombreCompleto.initials;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizing.radiusLg),
        boxShadow: [
          BoxShadow(
            color:      AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurMd,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius:          AppSizing.avatarRadiusMd,
            backgroundColor: avatarColor,
            child: Text(
              iniciales,
              style: AppTextStyles.titleSmall.copyWith(
                color:      AppColors.textOnDark,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombreCompleto,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Canal y estado — ocultos si no hay lead asociado, para no
                // mostrar datos falsos (ícono/chip vacíos).
                if (lead.descripcionCanal.isNotEmpty ||
                    lead.idEstado.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (lead.descripcionCanal.isNotEmpty) ...[
                        AppSocialUtils.widgetCanalById(
                          lead.idCanal,
                          size: AppSizing.iconSm,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            lead.descripcionCanal,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      if (lead.idEstado.isNotEmpty)
                        AppSocialUtils.chipEstado(
                          lead.idEstadoEfectivo,
                          label: lead.estadoEfectivo,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

