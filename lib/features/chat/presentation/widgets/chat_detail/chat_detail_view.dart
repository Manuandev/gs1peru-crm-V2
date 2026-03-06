// lib\features\chat\presentation\widgets\chat_detail\chat_detail_view.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailView extends StatefulWidget {
  final Chat chat;
  const ChatDetailView({super.key, required this.chat});

  @override
  State<ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<ChatDetailView> {
  final ScrollController _scrollController = ScrollController();
  final AudioController _audioController = AudioController();
  bool _isLoadingMore = false;
  bool _isInitialLoad = true;
  bool _showScrollDown = false;

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

    _isLoadingMore = true;
    context.read<ChatDetailBloc>().add(
      ChatDetailMoreMessagesLoaded(
        idLead: widget.chat.idLead,
        idUltimoMensaje: state.messages.first.idMensaje,
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
      title: widget.chat.nombreApe,
      drawerSide: DrawerSide.none,
      footer: const SizedBox.shrink(),
      appBarLeadingButtons: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.goBack(),
        ),
      ],
      body: Column(
        children: [
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
                            ChatDetailRefreshed(widget.chat.idLead),
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
                      idLead: widget.chat.idLead,
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

          // ── Input bar ──────────────────────────────────────
          ChatInputBar(
            chat: widget.chat,
            onScrollToBottom: () => _scrollToBottom(),
            audioController: _audioController,
          ),
        ],
      ),
    );
  }
}
