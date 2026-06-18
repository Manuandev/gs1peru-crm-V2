// lib/features/lead/presentation/widgets/contacto_detalle/contacto_detalle_header.dart

import 'package:flutter/material.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleHeader extends StatelessWidget {
  final ContactoDetalle contacto;

  const ContactoDetalleHeader({super.key, required this.contacto});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: AppSizing.shadowBlurMd,
            offset: const Offset(0, AppSizing.shadowOffsetCardY),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizing.avatarRadiusXl,
            backgroundColor: AvatarUtils.color(contacto.nombreCompleto),
            child: Text(
              AvatarUtils.initials(contacto.nombreCompleto),
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightBold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contacto.nombreCompleto,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: AppTextStyles.weightBold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (contacto.cargo.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    contacto.cargo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (contacto.empresa.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    contacto.empresa,
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
