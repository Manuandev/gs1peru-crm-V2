// lib/features/chat/presentation/widgets/chat_detail/chat_detail_view.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatDetailView extends StatefulWidget {
  final int idNumero;
  final int? idLead;
  final Chat? conversacion;
  const ChatDetailView({super.key, required this.idNumero, this.idLead, this.conversacion});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final _scroll = ChatScrollController();
  final AudioController _audioController = AudioController();
  final List<StreamSubscription<String>> _subs = [];

  bool _isLoadingMore = false;
  bool _isInitialLoad = true;
  bool _showScrollDown = false;

  DateTime? _lastLoadMoreTime;

  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _scroll.controller.addListener(_onScroll);
    AppRouteObserver.instance.setActiveLead(widget.idNumero);
    final cubit = context.read<InfoLeadCubit>();
    if (widget.conversacion != null) {
      cubit.seed(widget.conversacion!);
    } else if (widget.idLead != null) {
      cubit.load(widget.idLead!);
    }
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
    AppRouteObserver.instance.setActiveLead(null);
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BasePage(
      bodyPadding: EdgeInsets.zero,
      titleWidget: BlocBuilder<InfoLeadCubit, InfoLeadState>(
        buildWhen: (prev, curr) => curr is InfoLeadSuccess,
        builder: (context, state) => state is InfoLeadSuccess
            ? ChatDetailAppBar(lead: state.lead)
            : const SizedBox.shrink(),
      ),
      drawerSide: DrawerSide.none,
      footer: const SizedBox.shrink(),
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],

      appBarTrailingButtons: [
        IconButton(
          icon: const Icon(AppIcons.phone, color: AppColors.background),
          onPressed: widget.conversacion == null
              ? null
              : () => LauncherUtils.abrirTelefono(
                    '${widget.conversacion!.prefijoPais} ${widget.conversacion!.numero}',
                  ),
        ),
      ],

      appBarPopupItems: [
        AppBarPopupItem(
          value: 'datos',
          icon: Icons.assignment_outlined,
          label: 'Datos',
          subtitle: 'Información del lead',
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
          subtitle: 'Actividades y mensajes',
        ),
      ],
      onPopupSelected: (value) {
        final s = context.read<InfoLeadCubit>().state;
        if (s is! InfoLeadSuccess) return;
        final lead = s.lead;

        final tab = switch (value) {
          'datos' => LeadDetailTab.datos,
          'negociaciones' => LeadDetailTab.negociaciones,
          'historial' => LeadDetailTab.historial,
          _ => LeadDetailTab.datos,
        };

        LeadDetailSheet.show(
          context,
          initialTab: tab,
          lead: lead,
          leadId: lead.idLead,
          idNumero: widget.idNumero,
          cubit: context.read<InfoLeadCubit>(),
        );
      },
      body: Column(
        children: [
          BlocBuilder<InfoLeadCubit, InfoLeadState>(
            buildWhen: (prev, curr) {
              if (curr is! InfoLeadSuccess) return false;
              if (prev is! InfoLeadSuccess) return true;
              return (prev).lead.idEstado != (curr).lead.idEstado;
            },
            builder: (context, state) => state is InfoLeadSuccess
                ? ChatDetailFases(
                    idEstadoActual: state.lead.idEstado,
                    onEstadoTap: (estado) async {
                      final confirmar = await context.showConfirmDialog(
                        title: 'Confirmar cambio',
                        message:
                            '¿Deseas cambiar el estado a "${estado.label}"?',
                      );

                      if (!confirmar) return;

                      if (context.mounted) {
                        context.read<InfoLeadCubit>().updateEstado(
                          idNumero: widget.idNumero,
                          idEstado: estado.id,
                          estado: estado.label,
                        );
                      }
                    },
                  )
                : const SizedBox.shrink(),
          ),

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

                    return BlocBuilder<InfoLeadCubit, InfoLeadState>(
                      buildWhen: (prev, curr) {
                        if (curr is! InfoLeadSuccess) return false;
                        if (prev is! InfoLeadSuccess) return true;
                        return prev.lead.nombreCompleto !=
                            curr.lead.nombreCompleto;
                      },
                      builder: (context, infoState) {
                        final nombre = infoState is InfoLeadSuccess
                            ? infoState.lead.nombreCompleto
                            : '';

                        return MessageList(
                          messages: messages,
                          scrollController: _scroll.controller,
                          isLoadingMore: isLoadingMore,
                          audioController: _audioController,
                          idNumero: widget.idNumero,
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

          // BlocBuilder<InfoLeadCubit, InfoLeadState>(
          //   buildWhen: (prev, curr) => curr is InfoLeadSuccess,
          //   builder: (context, state) => state is InfoLeadSuccess
          //       ? ChatDetailDatosLead(infoLead: state.infoLead)
          //       : const SizedBox.shrink(),
          // ),
          BlocBuilder<ChatDetailBloc, ChatDetailState>(
            buildWhen: (prev, curr) {
              // Solo reconstruir cuando pasa de "activo" (Success o LoadingMore) a "inactivo" o viceversa
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
              return ChatInputBar(audioController: _audioController);
            },
          ),
        ],
      ),
    );
  }
}
