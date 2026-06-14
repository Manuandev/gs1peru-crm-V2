// lib/features/chat/presentation/widgets/chat_list/chat_list_portrait.dart

import 'package:flutter/material.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatListPortrait extends StatelessWidget {
  final ChatListSuccess state;

  const ChatListPortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.chats.length,
      itemBuilder: (context, index) {
        final chat = state.chats[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ChatTile(
            chat: chat,
            onTap: () => context.goToDetalleChat(idLead: chat.idLead),
            onResponderTap: () => context.goToDetalleChat(idLead: chat.idLead),
          ),
        );
      },
    );
  }
}
