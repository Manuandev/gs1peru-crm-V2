// lib/features/chat/presentation/pages/chat_detail_page.dart

import 'dart:async';
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
  Chat? _chat;
  bool _cargando = true;
  StreamSubscription<ContactoUpdate>? _contactoSub;

  @override
  void initState() {
    super.initState();
    _cargarChat();
    // EditContactoPortrait avisa por acá cuando el contacto de este número
    // se guarda — recarga el Chat en silencio (sin pasar por _cargando, no
    // se ve un salto de pantalla) para que "Datos" muestre nombre/apellido/
    // empresa actualizados sin que el usuario tenga que salir y reentrar.
    _contactoSub = ContactoUpdateNotifier.instance.stream.listen((event) {
      if (_chat != null && event.idNumero == _chat!.idNumero) {
        _cargarChat(silencioso: true);
      }
    });
  }

  @override
  void dispose() {
    _contactoSub?.cancel();
    super.dispose();
  }

  Future<void> _cargarChat({bool silencioso = false}) async {
    if (!silencioso && mounted) setState(() => _cargando = true);
    final chat = await GetChatByIdChatCabUseCase(
      context.read<ChatRepository>(),
    )(widget.idChatCab);
    if (!mounted) return;
    // En modo silencioso, si por algún motivo ya no hay chat (poco probable,
    // el número ya existía), no se pisa el que ya se estaba mostrando.
    if (silencioso && chat == null) return;
    setState(() {
      _chat = chat;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const _ChatDetailShell(body: AppLoadingView());
    }

    final chat = _chat;
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
            obtenerHistorialPorContactoUseCase:
                GetHistorialSeguimientoPorContacto(
                  context.read<LeadRepository>(),
                ),
          ),
        ),
      ],
      child: ChatDetailView(idNumero: chat.idNumero, conversacion: chat),
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
