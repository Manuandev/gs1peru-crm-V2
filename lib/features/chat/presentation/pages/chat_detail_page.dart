// lib\features\chat\presentation\pages\chat_detail_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailPage extends StatelessWidget {
  final int idLead;

  const ChatDetailPage({super.key, required this.idLead});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChatDetailBloc(
            GetChatMessagesUseCase(context.read<ChatRepository>()),
            SendChatMessageUseCase(context.read<ChatRepository>()),
            SendFileMessageUseCase(context.read<ChatRepository>()),
          )..add(ChatDetailStarted(idLead)),
        ),
        BlocProvider(
          create: (_) => InfoLeadCubit(
            GetInfoUseCase(context.read<ChatRepository>()),
            UpdateLeadEstadoUseCase(context.read<ChatRepository>()),
          ),
        ),
      ],
      child: ChatDetailView(idLead: idLead),
    );
  }
}
