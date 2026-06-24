// lib/features/chat/presentation/pages/chat_detail_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailPage extends StatelessWidget {
  final int idNumero;
  final Chat? conversacion;

  const ChatDetailPage({super.key, required this.idNumero, this.conversacion});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ChatDetailBloc(
            GetChatMessagesUseCase(context.read<ChatRepository>()),
            SendChatMessageUseCase(context.read<ChatRepository>()),
            SendFileMessageUseCase(context.read<ChatRepository>()),
            SendTemplateMessageUseCase(context.read<ChatRepository>()),
          )..add(ChatDetailStarted(idNumero)),
        ),
        BlocProvider(
          create: (_) => InfoLeadCubit(
            GetInfoUseCase(context.read<ChatRepository>()),
            UpdateLeadEstadoUseCase(context.read<ChatRepository>()),
            UpdateLeadInfoUseCase(context.read<ChatRepository>()),
          ),
        ),
      ],
      child: ChatDetailView(idNumero: idNumero, conversacion: conversacion),
    );
  }
}
