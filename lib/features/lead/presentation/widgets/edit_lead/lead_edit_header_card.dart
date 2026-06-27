// lib/features/lead/presentation/widgets/edit_lead/lead_edit_header_card.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Card de encabezado del formulario de edición de lead.
/// Muestra avatar con iniciales, nombre completo, canal, estado y empresa.
class LeadEditHeaderCard extends StatelessWidget {
  final Lead lead;
  const LeadEditHeaderCard({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarColor = lead.nombreCompleto.avatarColor;
    final iniciales   = lead.nombreCompleto.initials;

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
                  lead.nombreCompleto,
                  style: AppTextStyles.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    AppSocialUtils.widgetCanalById(lead.idCanal, size: AppSizing.iconSm),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        lead.canal,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppSocialUtils.chipEstado(
                      lead.idEstadoPadre?.isNotEmpty == true
                          ? lead.idEstadoPadre!
                          : lead.idEstado,
                      label: lead.idEstadoPadre?.isNotEmpty == true
                          ? lead.descripcionEstadoPadre ?? lead.estado
                          : lead.estado,
                    ),
                  ],
                ),
                if (lead.nombreEmpresa.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    lead.nombreEmpresa,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

