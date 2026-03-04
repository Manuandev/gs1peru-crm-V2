// lib/features/chats/presentation/widgets/chats_portrait.dart

import 'package:flutter/material.dart';
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
        return ChatTile(chat: chat, onTap: () {});
      },
    );
  }
}
