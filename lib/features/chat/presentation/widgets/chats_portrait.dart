// lib/features/chats/presentation/widgets/chats_portrait.dart

import 'package:flutter/material.dart';
import 'package:app_crm/features/chat/presentation/bloc/chats_state.dart';
import 'package:app_crm/features/chat/presentation/widgets/chat_tile.dart';

class ChatsPortrait extends StatelessWidget {
  final ChatsLoaded state;

  const ChatsPortrait({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.chats.isEmpty) {
      return const _EmptyChats();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: state.chats.length,
      itemBuilder: (context, index) {
        final chat = state.chats[index];
        return ChatTile(
          chat: chat,
          onTap: () {
          },
        );
      },
    );
  }
}

// ─── Estado vacío ──────────────────────────────────────────────────
class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay chats disponibles',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los chats aparecerán aquí',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}