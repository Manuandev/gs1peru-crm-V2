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
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizing.avatarRadiusMd,
            backgroundColor: AvatarUtils.color(contacto.nombreCompleto),
            child: Text(
              AvatarUtils.initials(contacto.nombreCompleto),
              style: AppTextStyles.titleSmall.copyWith(
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
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.textOnDark,
                    fontWeight: AppTextStyles.weightBold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_subtitulo.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    _subtitulo,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.white(AppColors.opacityOnPrimarySubtle),
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

  String get _subtitulo {
    final partes = [
      if (contacto.cargo.isNotEmpty) contacto.cargo,
      if (contacto.empresa.isNotEmpty) contacto.empresa,
    ];
    return partes.join(' · ');
  }
}
