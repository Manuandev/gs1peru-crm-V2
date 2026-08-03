// lib/features/chat/presentation/widgets/chat_detail/chat_detail_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailView extends StatefulWidget {
  final int idNumero;
  final Chat conversacion;
  const ChatDetailView({
    super.key,
    required this.idNumero,
    required this.conversacion,
  });

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView>
    with SingleTickerProviderStateMixin {
  final _scroll = ChatScrollController();
  final AudioController _audioController = AudioController();
  final List<StreamSubscription<String>> _subs = [];

  bool _isLoadingMore = false;
  bool _isInitialLoad = true;
  bool _showScrollDown = false;
  bool _showLeadPanel = false;
  late final TabController _panelTabController;

  DateTime? _lastLoadMoreTime;

  int _previousMessageCount = 0;
  ChatListBloc? _chatListBloc;

  // Selección de mensaje estilo WhatsApp — solo uno a la vez, activada con
  // long press (ver MessageList/MessageBubble). Mientras haya uno seleccionado
  // el AppBar cambia a modo "back + copiar" (ver build()).
  ChatMessage? _mensajeSeleccionado;

  @override
  void initState() {
    super.initState();
    _chatListBloc = context.read<ChatListBloc>();
    _panelTabController = TabController(length: 3, vsync: this);
    _scroll.controller.addListener(_onScroll);
    AppRouteObserver.instance.setActiveLead(widget.idNumero);
    final cubit = context.read<InfoLeadCubit>();
    _subs.addAll([
      cubit.successes.listen(
        // ignore: use_build_context_synchronously
        (msg) => AppSnackBar.success(context, msg, position: SnackPosition.top),
      ),
      // ignore: use_build_context_synchronously
      cubit.errores.listen((msg) => AppSnackBar.error(context, msg)),
    ]);
  }

  @override
  void dispose() {
    if (!(_chatListBloc?.isClosed ?? true)) {
      _chatListBloc!.add(const ChatListSilentRefreshed());
    }
    AppRouteObserver.instance.setActiveLead(null);
    _panelTabController.dispose();
    _scroll.dispose();
    _audioController.dispose();
    for (final s in _subs) {
      s.cancel();
    }
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

    // Si el mensaje más antiguo no tiene UUID real no hay anchor válido para la paginación
    final anchorToken = state.messages.first.idTokenMeta;
    if (anchorToken.isEmpty) return;

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
        idNumero: widget.idNumero,
        idUltimoMensaje: anchorToken,
      ),
    );
  }

  void _seleccionarMensaje(ChatMessage message) {
    setState(() => _mensajeSeleccionado = message);
  }

  void _limpiarSeleccion() {
    setState(() => _mensajeSeleccionado = null);
  }

  void _copiarMensajeSeleccionado() {
    final mensaje = _mensajeSeleccionado;
    if (mensaje == null) return;
    Clipboard.setData(ClipboardData(text: mensaje.contenido));
    _limpiarSeleccion();
    AppSnackBar.success(
      context,
      'Mensaje copiado',
      position: SnackPosition.top,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mensajeSeleccionado = _mensajeSeleccionado;
    final enSeleccion = mensajeSeleccionado != null;

    return BasePage(
      bodyPadding: EdgeInsets.zero,
      titleWidget: enSeleccion
          ? Text(
              '1 mensaje seleccionado',
              style: AppTextStyles.titleMedium.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: AppTextStyles.weightBold,
              ),
            )
          : BlocBuilder<InfoLeadCubit, InfoLeadState>(
              buildWhen: (prev, curr) => curr is InfoLeadSuccess,
              builder: (context, infoState) {
                if (infoState is! InfoLeadSuccess) {
                  return const SizedBox.shrink();
                }
                return BlocSelector<ChatDetailBloc, ChatDetailState, String?>(
                  selector: (state) {
                    final msgs = switch (state) {
                      ChatDetailSuccess s => s.messages,
                      ChatDetailLoadingMore s => s.messages,
                      _ => <ChatMessage>[],
                    };
                    for (var i = msgs.length - 1; i >= 0; i--) {
                      if (msgs[i].direccionMensaje == 'CLI') {
                        return msgs[i].fechaHora;
                      }
                    }
                    return null;
                  },
                  builder: (context, fechaUltimaRespuesta) => ChatDetailAppBar(
                    negociacion: infoState.negociacion,
                    nombreCompleto: widget.conversacion.nombreCompleto,
                    idCanal: infoState.negociacion.idCanal,
                    fechaUltimaRespuesta: fechaUltimaRespuesta,
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      context.goToEditarLead(
                        idLead: infoState.negociacion.idLead,
                        cubit: context.read<InfoLeadCubit>(),
                        desdeConversacion: true,
                      );
                    },
                  ),
                );
              },
            ),
      drawerSide: DrawerSide.none,
      footer: const SizedBox.shrink(),
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: enSeleccion ? _limpiarSeleccion : () => context.goBack(),
        ),
      ],

      appBarTrailingButtons: enSeleccion
          ? const []
          : [
              Builder(
                builder: (context) {
                  final chat = widget.conversacion;
                  final telefono = chat.numero.isNotEmpty
                      ? '${chat.prefijoPais} ${chat.numero}'.trim()
                      : null;
                  return IconButton(
                    icon: const Icon(
                      AppIcons.phone,
                      color: AppColors.background,
                    ),
                    onPressed: telefono == null
                        ? null
                        : () => LauncherUtils.abrirTelefono(telefono),
                  );
                },
              ),
            ],

      appBarPopupItems: enSeleccion
          ? [
              AppBarPopupItem(
                value: 'copiar',
                icon: AppIcons.copy,
                label: 'Copiar',
                showDividerAfter: false,
              ),
            ]
          : [
              AppBarPopupItem(
                value: 'datos',
                icon: Icons.assignment_outlined,
                label: 'Datos',
                subtitle: 'Información del contacto',
                showDividerAfter: false,
              ),
              AppBarPopupItem(
                value: 'negociaciones',
                icon: Icons.handshake_outlined,
                label: 'Negociaciones',
                subtitle: 'Gestiona sus negociaciones',
              ),
              AppBarPopupItem(
                value: 'historial',
                icon: Icons.history_outlined,
                label: 'Historial',
                subtitle: 'Actividades',
              ),
            ],
      onPopupSelected: (value) {
        if (enSeleccion) {
          if (value == 'copiar') _copiarMensajeSeleccionado();
          return;
        }
        if (context.read<InfoLeadCubit>().state is! InfoLeadSuccess) return;
        FocusScope.of(context).unfocus();
        final tabIndex = switch (value) {
          'negociaciones' => 1,
          'historial' => 2,
          _ => 0,
        };
        setState(() {
          _showLeadPanel = true;
          _panelTabController.animateTo(tabIndex);
        });
      },
      body: Column(
        children: [
          // ── Banner + fases: blanco puro para que la ola y las fases sean continuos ──
          ColoredBox(
            color: AppColors.surface,
            child: Column(
              children: [
                ChatOndaBanner(chat: widget.conversacion),
                BlocBuilder<InfoLeadCubit, InfoLeadState>(
                  buildWhen: (prev, curr) {
                    if (curr is! InfoLeadSuccess) return false;
                    if (prev is! InfoLeadSuccess) return true;
                    return prev.negociacion.idLead != curr.negociacion.idLead ||
                        prev.negociacion.idEstado !=
                            curr.negociacion.idEstado ||
                        prev.negociacion.idEstadoPadre !=
                            curr.negociacion.idEstadoPadre;
                  },
                  // Sin lead no hay etapa que mostrar — mostrar "paso 1" sería
                  // data falsa (el fallback interno de ChatDetailFases activa
                  // el primer paso cuando idEstado no matchea ningún estado).
                  builder: (context, state) =>
                      state is InfoLeadSuccess && state.negociacion.idLead > 0
                      ? ChatDetailFases(
                          idEstadoActual: state.negociacion.idEstado,
                          idEstadoPadre: state.negociacion.idEstadoPadre,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // ── Mensajes: fondo original del scaffold ──
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // ── BlocConsumer ───────────────────────────
                BlocConsumer<ChatDetailBloc, ChatDetailState>(
                  listener: (context, state) {
                    if (state is ChatDetailSuccess) {
                      final currentCount = state.messages.length;

                      if (_isInitialLoad) {
                        _isInitialLoad = false;
                        // Garantizar que el scroll está al fondo (mensajes más recientes)
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) _scroll.irAlFondo(animated: false);
                        });
                      } else if (_isLoadingMore) {
                        // Fue carga de paginación, no hacemos scroll automático hacia abajo
                      } else {
                        // Si se agregó un mensaje nuevo
                        if (currentCount > _previousMessageCount &&
                            state.messages.isNotEmpty) {
                          final nuevoMensaje = state.messages.last;
                          // Si yo lo envié O si estábamos al fondo (!showScrollDown)
                          if (nuevoMensaje.direccionMensaje == 'ASE' ||
                              !_showScrollDown) {
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
                      AppSnackBar.error(context, state.message);
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
                            ChatDetailRefreshed(widget.idNumero),
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
                      scrollController: _scroll.controller,
                      isLoadingMore: isLoadingMore,
                      audioController: _audioController,
                      idNumero: widget.idNumero,
                      nombre: widget.conversacion.nombreCompleto,
                      mensajeSeleccionado: mensajeSeleccionado,
                      onLongPressMessage: _seleccionarMensaje,
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

          if (_showLeadPanel)
            BlocBuilder<InfoLeadCubit, InfoLeadState>(
              buildWhen: (prev, curr) => curr is InfoLeadSuccess,
              builder: (context, state) {
                if (state is! InfoLeadSuccess) return const SizedBox.shrink();
                return ChatLeadPanel(
                  chat: widget.conversacion,
                  negociacion: state.negociacion,
                  idNumero: widget.idNumero,
                  tabController: _panelTabController,
                  cubit: context.read<InfoLeadCubit>(),
                  onClose: () => setState(() => _showLeadPanel = false),
                );
              },
            ),

          BlocBuilder<ChatDetailBloc, ChatDetailState>(
            buildWhen: (prev, curr) {
              final prevActivo =
                  prev is ChatDetailSuccess || prev is ChatDetailLoadingMore;
              final currActivo =
                  curr is ChatDetailSuccess || curr is ChatDetailLoadingMore;
              return prevActivo != currActivo;
            },
            builder: (context, state) {
              final activo =
                  state is ChatDetailSuccess || state is ChatDetailLoadingMore;
              if (!activo) return const SizedBox.shrink();
              return ChatInputBar(
                audioController: _audioController,
                chat: widget.conversacion,
                panelAbierto: _showLeadPanel,
              );
            },
          ),
        ],
      ),
    );
  }
}
