import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';

class ChatTileHome extends StatelessWidget {
  final Chat chat;
  const ChatTileHome({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Row(
        children: [
          // ── FECHA/HORA ────────────────────────────────────
          Text(
            chat.nombreApe,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // ── ID + FUENTE ───────────────────────────────────
          Expanded(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: chat.mensaje,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: chat.fechaHora.formatDate(AppDateFormat.shortDate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
