// lib\features\chat\presentation\widgets\chat_detail\chat_detail_view.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailView extends StatefulWidget {
  final String idLead;
  const ChatDetailView({super.key, required this.idLead});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final ScrollController _scrollController = ScrollController();
  final AudioController _audioController = AudioController();
  bool _isLoadingMore = false;
  bool _isInitialLoad = true;
  bool _showScrollDown = false;
  DateTime? _lastLoadMoreTime;

  // 👇 Agrega esta variable al State
  double _scrollOffsetAntesDeCarga = 0;
  // 👇 Cambia la variable
  double _pixelsAntesDeCarga = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _audioController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // ── Botón scroll down ──────────────────────────────
    final atBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100;

    final shouldShow = !atBottom; // ← mostrar cuando NO está al fondo
    if (_showScrollDown != shouldShow) {
      setState(() => _showScrollDown = shouldShow);
    }

    // ── Paginación ─────────────────────────────────────
    if (_scrollController.position.pixels >
        _scrollController.position.minScrollExtent + 80) {
      return;
    }

    final state = context.read<ChatDetailBloc>().state;
    if (state is! ChatDetailSuccess) return;
    if (!state.hasMore) return;
    if (_isLoadingMore) return;

    // ✅ Debounce: evita múltiples disparos en menos de 500ms
    final now = DateTime.now();
    if (_lastLoadMoreTime != null &&
        now.difference(_lastLoadMoreTime!) <
            const Duration(milliseconds: 500)) {
      return;
    }
    _lastLoadMoreTime = now;

    final mensajeMasAntiguo = state.messages.first.idMensaje;

    // 👇 En _onScroll, guarda el offset ANTES de disparar la carga
    _scrollOffsetAntesDeCarga = _scrollController.position.maxScrollExtent;
    _pixelsAntesDeCarga = _scrollController.position.pixels;
    _isLoadingMore = true;
    context.read<ChatDetailBloc>().add(
      ChatDetailMoreMessagesLoaded(
        idLead: widget.idLead,
        idUltimoMensaje: mensajeMasAntiguo,
      ),
    );
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      // Forzar el extent más reciente
      final maxExtent = _scrollController.position.maxScrollExtent;

      if (animated) {
        _scrollController.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(maxExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      titleWidget: BlocBuilder<InfoLeadCubit, InfoLeadState>(
        buildWhen: (prev, curr) => curr is InfoLeadSuccess,
        builder: (context, state) => state is InfoLeadSuccess
            ? ChatDetailAppBar(infoLead: state.infoLead)
            : const SizedBox.shrink(),
      ),
      drawerSide: DrawerSide.none,
      footer: const SizedBox.shrink(),
      // 👇 botón back
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],

      // 👇 estrella + 3 puntos
      appBarTrailingButtons: [
        BlocBuilder<InfoLeadCubit, InfoLeadState>(
          buildWhen: (prev, curr) {
            if (curr is! InfoLeadSuccess) return false;
            if (prev is! InfoLeadSuccess) return true;
            return (prev).infoLead.isFavorito != (curr).infoLead.isFavorito;
          },
          builder: (context, state) {
            final favorito = state is InfoLeadSuccess
                ? state.infoLead.isFavorito
                : false;
            return IconButton(
              icon: Icon(
                favorito ? Icons.star_rounded : Icons.star_border_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: state is InfoLeadSuccess
                  ? () =>
                        context.read<InfoLeadCubit>().updateFavorito(!favorito)
                  : null,
            );
          },
        ),
      ],

      // 👇 3 puntos via appBarPopupItems
      appBarPopupItems: [
        AppBarPopupItem(
          value: 'bloquear',
          icon: Icons.block,
          label: 'Bloquear',
        ),
        AppBarPopupItem(
          value: 'ver_lead',
          icon: Icons.person,
          label: 'Ver lead',
        ),
      ],
      onPopupSelected: (value) {
        switch (value) {
          case 'bloquear':
            // acción bloquear
            break;
          case 'ver_lead':
            // acción ver lead
            break;
        }
      },
      body: Column(
        children: [
          BlocBuilder<InfoLeadCubit, InfoLeadState>(
            buildWhen: (prev, curr) {
              if (curr is! InfoLeadSuccess) return false;
              if (prev is! InfoLeadSuccess) return true;
              return (prev).infoLead.idEstado != (curr).infoLead.idEstado;
            },
            builder: (context, state) => state is InfoLeadSuccess
                ? ChatDetailFases(
                    idEstadoActual: state.infoLead.idEstado,
                    onEstadoTap: (estado) {
                      // aquí llamas tu cubit para cambiar estado
                      context.read<InfoLeadCubit>().updateEstado(
                        idEstado: estado.id,
                        estado: estado.label,
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
          // ── Lista de mensajes + botón scroll ──────────────
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── BlocConsumer ───────────────────────────
                BlocConsumer<ChatDetailBloc, ChatDetailState>(
                  listener: (context, state) {
                    if (state is ChatDetailSuccess) {
                      if (_isInitialLoad) {
                        _isInitialLoad = false;
                        _scrollToBottom(animated: false);
                      } else if (_isLoadingMore) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!_scrollController.hasClients) return;
                          final nuevoMaxExtent =
                              _scrollController.position.maxScrollExtent;
                          final anteriorMaxExtent = _scrollOffsetAntesDeCarga;
                          final alturaNuevosMensajes =
                              nuevoMaxExtent - anteriorMaxExtent;
                          _scrollController.jumpTo(
                            _pixelsAntesDeCarga + alturaNuevosMensajes,
                          );
                        });
                      }
                      _isLoadingMore = false;
                    }
                    if (state is ChatDetailFailure) {
                      _isLoadingMore = false;
                      context.showErrorSnack(state.message);
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatDetailInitial ||
                        state is ChatDetailLoading) {
                      return const AppLoadingView();
                    }

                    if (state is ChatDetailFailure) {
                      return AppErrorView(
                        message: state.message,
                        onRetry: () {
                          _isInitialLoad = true;
                          context.read<ChatDetailBloc>().add(
                            ChatDetailRefreshed(widget.idLead),
                          );
                        },
                      );
                    }

                    final messages = switch (state) {
                      ChatDetailSuccess s => s.messages,
                      ChatDetailLoadingMore s => s.messages,
                      _ => <ChatMessage>[],
                    };

                    final isLoadingMore = state is ChatDetailLoadingMore;

                    if (messages.isEmpty) {
                      return const AppEmptyView(
                        message: 'Aún no hay mensajes.',
                      );
                    }

                    return MessageList(
                      messages: messages,
                      scrollController: _scrollController,
                      isLoadingMore: isLoadingMore,
                      audioController: _audioController,
                      idLead: widget.idLead,
                      blockScroll: _isLoadingMore,
                    );
                  },
                ),

                // ── Botón scroll al fondo ──────────────────
                if (_showScrollDown)
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        if (!_scrollController.hasClients) return;
                        _scrollController.jumpTo(
                          _scrollController.position.maxScrollExtent,
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.onPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          BlocBuilder<InfoLeadCubit, InfoLeadState>(
            buildWhen: (prev, curr) => curr is InfoLeadSuccess,
            builder: (context, state) => state is InfoLeadSuccess
                ? ChatDetailDatosLead(infoLead: state.infoLead)
                : const SizedBox.shrink(),
          ),
          // ── Input bar ──────────────────────────────────────
          ChatInputBar(
            onScrollToBottom: () => _scrollToBottom(),
            audioController: _audioController,
          ),
        ],
      ),
    );
  }
}
