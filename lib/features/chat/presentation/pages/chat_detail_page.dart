// lib\features\chat\presentation\pages\chat_detail_page.dart

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailPage extends StatelessWidget {
  final Chat chat;

  const ChatDetailPage({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatDetailBloc(
        GetChatMessagesUseCase(context.read<ChatRepository>()),
      )..add(ChatDetailStarted(chat.idLead)),
      child: ChatDetailView(chat: chat),
    );
  }
}