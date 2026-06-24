// lib/features/chat/presentation/widgets/chat_detail/chat_detail_app_bar.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatDetailAppBar extends StatelessWidget {
  final Lead lead;
  const ChatDetailAppBar({super.key, required this.lead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // ── Avatar con iniciales ──
        CircleAvatar(
          radius: AppSizing.avatarRadiusAppBar,
          backgroundColor: lead.nombreCompleto.avatarColor,
          child: Text(
            lead.nombreCompleto.initials,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: AppTextStyles.weightBold,
              color: AppColors.textOnDark,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.smPlus),

        // ── Nombre + canal ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lead.nombreCompleto,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: AppTextStyles.weightBold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(
                    AppIcons.campaign,
                    size: AppSizing.iconXxs,
                    color: colorScheme.onPrimary.withValues(
                      alpha: AppColors.opacityOnPrimarySubtle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    lead.canal.isEmpty ? 'Sin canal' : lead.canal,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: colorScheme.onPrimary.withValues(
                        alpha: AppColors.opacityOnPrimarySubtle,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxs),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.brandForest,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (true) ...[
                    Text(
                      'Derivado IA • ',
                      style: AppTextStyles.labelVerySmall8.copyWith(
                        color: colorScheme.onPrimary.withValues(
                          alpha: AppColors.opacityOnPrimarySubtle,
                        ),
                      ),
                    ),
                  ],
                  Text(
                    'Ultima respuesta hace 2 min',
                    style: AppTextStyles.labelVerySmall8.copyWith(
                      color: colorScheme.onPrimary.withValues(
                        alpha: AppColors.opacityOnPrimarySubtle,
                      ),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
