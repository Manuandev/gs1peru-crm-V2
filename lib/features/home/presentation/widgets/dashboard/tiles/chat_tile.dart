import 'package:app_crm/core/constants/app_spacing.dart';
import 'package:app_crm/core/constants/app_text_styles.dart';
import 'package:app_crm/core/utils/date/date_extensions.dart';
import 'package:app_crm/core/utils/date/date_formats.dart';
import 'package:app_crm/features/chat/data/models/chat_model.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final ChatItem chat;
  const ChatTile({super.key, required this.chat});

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
