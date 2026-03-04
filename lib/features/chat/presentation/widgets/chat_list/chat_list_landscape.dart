// lib/features/chats/presentation/widgets/chats_landscape.dart

import 'package:flutter/material.dart';
import 'package:app_crm/features/chat/index_chat.dart';

/// Vista landscape: misma lista pero centrada con ancho máximo
/// para que no se vea muy estirada en pantallas anchas (tablet/desktop).
class ChatListLandscape extends StatelessWidget {
  final ChatListSuccess state;

  const ChatListLandscape({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        // Máximo 720px de ancho en landscape para que no se deforme
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: state.chats.length,
          itemBuilder: (context, index) {
            final chat = state.chats[index];
            return ChatTile(chat: chat, onTap: () {});
          },
        ),
      ),
    );
  }
}
