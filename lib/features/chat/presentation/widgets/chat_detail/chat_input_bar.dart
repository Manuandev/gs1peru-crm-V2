// lib\features\chat\presentation\widgets\chat_detail\chat_input_bar.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatInputBar extends StatefulWidget {
  final AudioController audioController;

  const ChatInputBar({super.key, required this.audioController});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();

  InputMode _mode = InputMode.text;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatDetailBloc>().add(
      ChatDetailTextMessageSent(
        text,
        numero: _getNumero(),
        chatCab: _getChatCab(),
      ),
    );
    _textController.clear();
  }

  String _getNumero() {
    final infoState = context.read<InfoLeadCubit>().state;
    if (infoState is InfoLeadSuccess) {
      return infoState.infoLead.telefono.replaceAll(RegExp(r'[^0-9]'), '');
    }
    return '';
  }

  String _getChatCab() {
    final chatState = context.read<ChatDetailBloc>().state;
    if (chatState is ChatDetailSuccess && chatState.messages.isNotEmpty) {
      return chatState.messages.first.idChatCab;
    }
    return '';
  }

  void _onAudioReady(String path) {
    widget.audioController.stop();
    context.read<ChatDetailBloc>().add(
      ChatDetailAudioMessageSent(
        path,
        numero: _getNumero(),
        chatCab: _getChatCab(),
      ),
    );
    setState(() => _mode = InputMode.text);
  }

  void _onFilesBatchPicked(List<StagedFile> files) {
    if (files.isEmpty) return;
    widget.audioController.stop();
    context.read<ChatDetailBloc>().add(
      ChatDetailBatchFileMessageSent(
        files: files,
        numero: _getNumero(),
        chatCab: _getChatCab(),
      ),
    );
    setState(() => _mode = InputMode.text);
  }

  void _toggleAttachment() {
    widget.audioController.stop();
    setState(
      () => _mode = _mode == InputMode.attachment
          ? InputMode.text
          : InputMode.attachment,
    );
  }

  Future<void> _onTemplateSelected() async {
    final infoState = context.read<InfoLeadCubit>().state;
    if (infoState is! InfoLeadSuccess) return;

    final template = await context.goToTemplates(lead: infoState.infoLead);
    if (template == null || !context.mounted) return;

    final info = infoState.infoLead;

    // ignore: use_build_context_synchronously
    context.read<ChatDetailBloc>().add(
      ChatDetailTemplateMessageSent(
        template: template,
        numero: info.telefono.replaceAll(RegExp(r'[^0-9]'), ''),
        chatCab: _getChatCab(),
        nombreCliente: info.nombre,
        apellidoCliente: info.apellido,
        isExpirado: info.isExpirado,
        isCerrado: info.isCerrado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeText = theme.textTheme;

    final bodyStyle = themeText.bodyMedium?.copyWith(
      color: themeText.bodyMedium!.color,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Attachment picker (mostrar/ocultar) ───────────────
        if (_mode == InputMode.attachment)
          AttachmentPickerWidget(
            onFilesBatchPicked: _onFilesBatchPicked,
            onClose: () => setState(() => _mode = InputMode.text),
          ),

        // ── Audio recorder ────────────────────────────────────
        if (_mode == InputMode.audio)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm2,
              vertical: AppSpacing.sm,
            ),
            child: AudioRecorderWidget(
              onAudioReady: _onAudioReady,
              onCancel: () => setState(() => _mode = InputMode.text),
            ),
          ),

        // ── Input principal ───────────────────────────────────
        if (_mode != InputMode.audio)
          BlocBuilder<InfoLeadCubit, InfoLeadState>(
            buildWhen: (prev, curr) {
              if (curr is! InfoLeadSuccess) return false;
              if (prev is! InfoLeadSuccess) return true;
              return prev.infoLead.isExpirado != curr.infoLead.isExpirado;
            },
            builder: (context, state) {
              final expirado = state is InfoLeadSuccess
                  ? state.infoLead.isExpirado
                  : false;

              if (expirado) {
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: AppSizing.borderWidthSubtle,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Botón plantilla
                      IconButton(
                        icon: Icon(
                          AppIcons.plantillas,
                          color: colorScheme.primary,
                        ),
                        onPressed: _onTemplateSelected,
                      ),
                      Expanded(
                        child: Text(
                          'Sesión cerrada, debes usar una plantilla debido a que el cliente no ha escrito en las últimas 24 horas.',
                          style: bodyStyle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: AppSizing.borderWidthSubtle,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Adjuntar
                    IconButton(
                      icon: Icon(
                        _mode == InputMode.attachment
                            ? AppIcons.close
                            : AppIcons.attach,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: _toggleAttachment,
                    ),
                    IconButton(
                      icon: Icon(
                        AppIcons.plantillas,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: _onTemplateSelected,
                    ),

                    // Campo de texto
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: AppSizing.inputMaxHeight,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppSizing.radiusXl),
                        ),
                        child: TextField(
                          controller: _textController,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escribe un mensaje...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.smPlus,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendText(),
                        ),
                      ),
                    ),

                    const SizedBox(width: AppSpacing.xs),

                    // Enviar texto o activar audio
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: _hasText
                          ? IconButton(
                              key: const ValueKey('send'),
                              icon: Icon(
                                AppIcons.send,
                                color: colorScheme.primary,
                              ),
                              onPressed: _sendText,
                            )
                          : IconButton(
                              key: const ValueKey('mic'),
                              icon: Icon(
                                AppIcons.mic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                widget.audioController.stop();
                                setState(() => _mode = InputMode.audio);
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
