// lib/features/chat/presentation/widgets/chat_detail/info_lead/chat_ia_banner.dart
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';

/// Banner informativo que aparece cuando un lead fue atendido inicialmente por el bot.
/// Los datos son estáticos por ahora; la lógica se conecta en una iteración posterior.
class ChatIaBanner extends StatelessWidget {
  const ChatIaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.iaBannerBg,
        borderRadius: BorderRadius.circular(AppSizing.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ícono sparkle ──
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.iaBannerIconBg,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: const Icon(
              AppIcons.sparkle,
              size: AppSizing.iconMd,
              color: AppColors.iaBannerFg,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Texto central ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Este lead fue gestionado inicialmente por el bot',
                  style: AppTextStyles.bodySub.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'El bot respondió las primeras preguntas y transfirió esta conversación '
                  'a ti porque el cliente solicitó información de precios y una consulta específica.',
                  style: AppTextStyles.labelVerySmall9.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm2),
          // ── Badge "Transferido" ──
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.iaBannerBadgeBg,
              borderRadius: BorderRadius.circular(AppSizing.radiusSm),
            ),
            child: Text(
              'Transferido a ti\nhace 12 min',
              style: AppTextStyles.labelVerySmall9.copyWith(
                color: AppColors.textOnDark,
                fontWeight: AppTextStyles.weightBold,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
