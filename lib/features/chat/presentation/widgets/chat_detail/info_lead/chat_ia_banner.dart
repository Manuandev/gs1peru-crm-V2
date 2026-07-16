// lib/features/chat/presentation/widgets/chat_detail/info_lead/chat_ia_banner.dart
import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

/// Banner informativo que aparece cuando un lead fue atendido inicialmente por el bot.
/// Solo se muestra cuando chat.isDerivadoIA == true.
class ChatIaBanner extends StatelessWidget {
  final Chat chat;
  const ChatIaBanner({super.key, required this.chat});

  String _badgeTexto() {
    final fecha = DateFormatter.parseDate(chat.fcUltimoMensajeIA);
    if (fecha == null) return 'Transferido a ti';
    final elapsed = DateTime.now().difference(fecha);
    return 'Transferido a ti\nhace ${ElapsedTimeUtils.formatHyM(elapsed)}';
  }

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
              size: AppSizing.iconActionSm,
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
                  'Esta conversación fue gestionada inicialmente por el bot',
                  style: AppTextStyles.bodySub.copyWith(
                    fontWeight: AppTextStyles.weightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'El bot atendió ${chat.cantidadMensajesIA} '
                  '${chat.cantidadMensajesIA == 1 ? 'mensaje' : 'mensajes'}.',
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
              _badgeTexto(),
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
