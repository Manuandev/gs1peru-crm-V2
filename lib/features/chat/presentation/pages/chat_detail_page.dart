// lib/features/chat/presentation/pages/chat_detail_page.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

/// Punto de entrada único al detalle de un chat — sin importar si se navega
/// desde la lista de chats, la lista de leads o el home, todos mandan
/// [idChatCab] y esta página resuelve el [Chat] completo con el mismo
/// lookup (task 'LU'), para que todos los flujos traigan siempre lo mismo.
class ChatDetailPage extends StatefulWidget {
  final int idChatCab;
  const ChatDetailPage({super.key, required this.idChatCab});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  late final Future<Chat?> _chatFuture;

  @override
  void initState() {
    super.initState();
    _chatFuture = GetChatByIdChatCabUseCase(
      context.read<ChatRepository>(),
    )(widget.idChatCab);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Chat?>(
      future: _chatFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _ChatDetailShell(body: AppLoadingView());
        }

        final chat = snapshot.data;
        if (chat == null) {
          return _ChatDetailShell(
            body: AppErrorView(
              message: 'No se encontró la conversación.',
              onRetry: () => context.goBack(),
            ),
          );
        }

        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => ChatDetailBloc(
                GetChatMessagesUseCase(context.read<ChatRepository>()),
                SendChatMessageUseCase(context.read<ChatRepository>()),
                SendFileMessageUseCase(context.read<ChatRepository>()),
                SendTemplateMessageUseCase(context.read<ChatRepository>()),
              )..add(ChatDetailStarted(chat.idNumero)),
            ),
            BlocProvider(
              create: (_) => InfoLeadCubit(
                GetInfoUseCase(context.read<ChatRepository>()),
                UpdateLeadEstadoUseCase(context.read<ChatRepository>()),
                UpdateLeadInfoUseCase(context.read<LeadRepository>()),
              )..seed(chat),
            ),
            BlocProvider(
              create: (_) => NegociacionesCubit(
                obtenerNegociacionesUseCase:
                    GetNegociacionesLead(LeadRepositoryImpl(LeadRemoteDatasource())),
              ),
            ),
            BlocProvider(
              create: (_) => HistorialLeadCubit(
                obtenerHistorialPorNumeroUseCase: GetHistorialSeguimientoPorNumero(
                  context.read<LeadRepository>(),
                ),
              ),
            ),
          ],
          child: ChatDetailView(idNumero: chat.idNumero, conversacion: chat),
        );
      },
    );
  }
}

/// Cascarón mínimo para los estados de carga/error previos a resolver el
/// chat — mismo chrome (sin drawer, sin footer, back simple) que usa
/// ChatDetailView una vez cargado, para que no haya un salto visual.
class _ChatDetailShell extends StatelessWidget {
  final Widget body;
  const _ChatDetailShell({required this.body});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: 'Conversación',
      drawerSide: DrawerSide.none,
      footer: const SizedBox.shrink(),
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],
      body: body,
    );
  }
}
