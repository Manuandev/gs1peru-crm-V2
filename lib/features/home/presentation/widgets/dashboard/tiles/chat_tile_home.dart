import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';

class ChatTileHome extends StatelessWidget {
  final Chat chat;
  const ChatTileHome({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = chat.nombreApe.initials;
    final avatarBg = chat.nombreApe.avatarColor;

    return InkWell(
      onTap: () => context.goToDetalleChatDesdeHome(chat: chat),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            // ── AVATAR ────────────────────────────────────────
            CircleAvatar(
              radius: 22,
              // ignore: deprecated_member_use
              backgroundColor: avatarBg.withOpacity(0.15),
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: avatarBg,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── CONTENIDO CENTRAL ─────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre
                  Text(
                    chat.nombreApe,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Mensaje preview
                  Text(
                    chat.mensaje,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // ── FECHA ─────────────────────────────────────────
            Text(
              chat.fechaHora.formatWhatsApp(),
              style: AppTextStyles.labelSmall.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
