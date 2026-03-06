// lib\features\chat\presentation\widgets\chat_detail\chat_input_bar.dart

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum _InputMode { text, audio, attachment }

class ChatInputBar extends StatefulWidget {
  final Chat chat;
  final VoidCallback onScrollToBottom;
  final AudioController audioController;

  const ChatInputBar({
    super.key,
    required this.chat,
    required this.onScrollToBottom,
    required this.audioController,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  _InputMode _mode = _InputMode.text;
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

    context.read<ChatDetailBloc>().add(ChatDetailTextMessageSent(text));
    _textController.clear();
    widget.onScrollToBottom();
  }

  void _onAudioReady(String path) {
    widget.audioController.stop();
    context.read<ChatDetailBloc>().add(ChatDetailAudioMessageSent(path));
    setState(() => _mode = _InputMode.text);
    widget.onScrollToBottom();
  }

  void _onFilePicked(String path, String name, String ext, String tipo) {
    widget.audioController.stop();
    context.read<ChatDetailBloc>().add(
      ChatDetailFileMessageSent(
        filePath: path,
        fileName: name,
        fileExt: ext,
        tipo: tipo,
      ),
    );
    setState(() => _mode = _InputMode.text);
    widget.onScrollToBottom();
  }

  void _toggleAttachment() {
    widget.audioController.stop();
    setState(
      () => _mode = _mode == _InputMode.attachment
          ? _InputMode.text
          : _InputMode.attachment,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Attachment picker (mostrar/ocultar) ───────────────
        if (_mode == _InputMode.attachment)
          AttachmentPickerWidget(
            onFilePicked: _onFilePicked,
            onClose: () => setState(() => _mode = _InputMode.text),
          ),

        // ── Audio recorder ────────────────────────────────────
        if (_mode == _InputMode.audio)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: AudioRecorderWidget(
              onAudioReady: _onAudioReady,
              onCancel: () => setState(() => _mode = _InputMode.text),
            ),
          ),

        // ── Input principal ───────────────────────────────────
        if (_mode != _InputMode.audio)
          Container(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outlineVariant, width: 0.8),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Adjuntar
                IconButton(
                  icon: Icon(
                    _mode == _InputMode.attachment
                        ? Icons.close_rounded
                        : Icons.attach_file_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _toggleAttachment,
                ),

                // Campo de texto
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 120),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Enviar texto o activar audio
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: _hasText
                      ? IconButton(
                          key: const ValueKey('send'),
                          icon: Icon(
                            Icons.send_rounded,
                            color: colorScheme.primary,
                          ),
                          onPressed: _sendText,
                        )
                      : IconButton(
                          key: const ValueKey('mic'),
                          icon: Icon(
                            Icons.mic_rounded,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            widget.audioController.stop();
                            setState(() => _mode = _InputMode.audio);
                          },
                        ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
