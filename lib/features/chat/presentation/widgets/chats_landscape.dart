// lib/features/chats/presentation/widgets/chats_landscape.dart

import 'package:flutter/material.dart';
import 'package:app_crm/features/chat/presentation/bloc/chats_state.dart';
import 'package:app_crm/features/chat/presentation/widgets/chat_tile.dart';

/// Vista landscape: misma lista pero centrada con ancho máximo
/// para que no se vea muy estirada en pantallas anchas (tablet/desktop).
class ChatsLandscape extends StatelessWidget {
  final ChatsLoaded state;

  const ChatsLandscape({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.chats.isEmpty) {
      return const _EmptyChats();
    }

    return Center(
      child: ConstrainedBox(
        // Máximo 720px de ancho en landscape para que no se deforme
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
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
        ),
      ),
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