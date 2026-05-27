// lib\features\chat\presentation\widgets\chat_detail\chat_detail_app_bar.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailAppBar extends StatelessWidget {
  final InfoLead infoLead;
  const ChatDetailAppBar({super.key, required this.infoLead});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // ── Avatar con iniciales ──
        CircleAvatar(
          radius: 20,
          backgroundColor: infoLead.cliente.avatarColor,
          child: Text(
            infoLead.cliente.initials,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),

        // ── Nombre + canal ──
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                infoLead.cliente,
                style: AppTextStyles.titleMedium.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Icon(
                    Icons.campaign_rounded,
                    size: 13,
                    // ignore: deprecated_member_use
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    infoLead.canal,
                    style: AppTextStyles.labelSmall.copyWith(
                      // ignore: deprecated_member_use
                      color: colorScheme.onPrimary.withOpacity(0.8),
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
