// lib\features\chat\presentation\widgets\chat_detail\chat_detail_view.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailView extends StatefulWidget {
  final int idLead;
  const ChatDetailView({super.key, required this.idLead});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final _scroll = ChatScrollController();
  final AudioController _audioController = AudioController();

  bool _isLoadingMore = false;
  bool _isInitialLoad = true;
  bool _showScrollDown = false;

  DateTime? _lastLoadMoreTime;

  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scroll.controller.addListener(_onScroll);
    AppRouteObserver.instance.setActiveLead(widget.idLead);
    context.read<InfoLeadCubit>().load(widget.idLead);
  }

  @override
  void dispose() {
    AppRouteObserver.instance.setActiveLead(null);
    _scroll.dispose();
    _audioController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.controller.hasClients) return;
    final pos = _scroll.controller.position;

    // botón scroll down
    // Con reverse: true, el fondo está en pixels == 0.0
    final notAtBottom = pos.pixels > 100;
    if (_showScrollDown != notAtBottom) {
      setState(() => _showScrollDown = notAtBottom);
    }

    // paginación (cuando llegamos arriba, que es maxScrollExtent)
    if (pos.pixels < pos.maxScrollExtent - 80) return;

    final state = context.read<ChatDetailBloc>().state;
    if (state is! ChatDetailSuccess || !state.hasMore || _isLoadingMore) return;

    final now = DateTime.now();
    if (_lastLoadMoreTime != null &&
        now.difference(_lastLoadMoreTime!) <
            const Duration(milliseconds: 500)) {
      return;
    }
    _lastLoadMoreTime = now;

    _isLoadingMore = true;

    context.read<ChatDetailBloc>().add(
      ChatDetailMoreMessagesLoaded(
        idLead: widget.idLead,
        idUltimoMensaje: state.messages.first.idMensaje,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      bodyPadding: EdgeInsets.zero,
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
      ],
      onPopupSelected: (value) {
        switch (value) {
          case 'bloquear':
            // acción bloquear
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
                      context.read<InfoLeadCubit>().updateEstado(
                        idEstado: estado.id,
                        estado: estado.label,
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── BlocConsumer ───────────────────────────
                BlocConsumer<ChatDetailBloc, ChatDetailState>(
                  listener: (context, state) {
                    if (state is ChatDetailSuccess) {
                      final currentCount = state.messages.length;

                      if (_isInitialLoad) {
                        _isInitialLoad = false;
                      } else if (_isLoadingMore) {
                        // Fue carga de paginación, no hacemos scroll automático hacia abajo
                      } else {
                        // Si se agregó un mensaje nuevo
                        if (currentCount > _previousMessageCount &&
                            state.messages.isNotEmpty) {
                          final nuevoMensaje = state.messages.last;
                          // Si yo lo envié O si estábamos al fondo (!showScrollDown)
                          if (nuevoMensaje.isEnviado || !_showScrollDown) {
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () {
                                _scroll.irAlFondo(animated: true);
                              },
                            );
                          }
                        }
                      }

                      _previousMessageCount = currentCount;
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

                    return BlocBuilder<InfoLeadCubit, InfoLeadState>(
                      builder: (context, infoState) {
                        final nombre = infoState is InfoLeadSuccess
                            ? infoState.infoLead.cliente
                            : '';

                        return MessageList(
                          messages: messages,
                          scrollController: _scroll.controller,
                          isLoadingMore: isLoadingMore,
                          audioController: _audioController,
                          idLead: widget.idLead,
                          nombre: nombre,
                        );
                      },
                    );
                  },
                ),

                // ── Botón scroll al fondo ──────────────────
                if (_showScrollDown)
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => _scroll.irAlFondo(),
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

          BlocBuilder<ChatDetailBloc, ChatDetailState>(
            buildWhen: (prev, curr) => curr is ChatDetailSuccess,
            builder: (context, state) {
              if (state is! ChatDetailSuccess) return const SizedBox.shrink();
              return ChatInputBar(audioController: _audioController);
            },
          ),
        ],
      ),
    );
  }
}
