// lib/features/chat/presentation/pages/chat_detail_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatDetailPage extends StatelessWidget {
  final int idNumero;
  final int? idLead;
  final Chat? conversacion;

  const ChatDetailPage({
    super.key,
    required this.idNumero,
    this.idLead,
    this.conversacion,
  });

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
            UpdateLeadInfoUseCase(context.read<LeadRepository>()),
          ),
        ),
        BlocProvider(
          create: (_) => NegociacionesCubit(
            obtenerNegociacionesUseCase:
                GetNegociacionesLead(LeadRepositoryImpl(LeadRemoteDatasource())),
          ),
        ),
        BlocProvider(create: (_) => HistorialLeadCubit()),
      ],
      child: ChatDetailView(
        idNumero: idNumero,
        idLead: idLead,
        conversacion: conversacion,
      ),
    );
  }
}
