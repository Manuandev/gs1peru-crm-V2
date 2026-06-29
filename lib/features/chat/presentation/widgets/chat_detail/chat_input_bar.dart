// lib/features/chat/presentation/widgets/chat_detail/chat_input_bar.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
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
      return infoState.lead.numero.replaceAll(RegExp(r'[^0-9]'), '');
    }
    return '';
  }

  String _getChatCab() {
    final chatState = context.read<ChatDetailBloc>().state;
    final messages = switch (chatState) {
      ChatDetailSuccess s => s.messages,
      ChatDetailLoadingMore s => s.messages,
      _ => <ChatMessage>[],
    };
    if (messages.isEmpty) return '';
    return messages.first.idConversacionCab.toString();
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
    final plantilla = await SelectTemplateModal.show(context);
    if (plantilla == null || !mounted) return;

    final infoState = context.read<InfoLeadCubit>().state;
    final nombreCliente = infoState is InfoLeadSuccess
        ? infoState.lead.nombre
        : '';
    final apellidoCliente = infoState is InfoLeadSuccess
        ? infoState.lead.apellido
        : '';
    final nombreAsesor = SessionService().userApe;

    final texto = plantilla.contenido
        .replaceAll('{{nombre_cliente}}', nombreCliente)
        .replaceAll('{{apellido_cliente}}', apellidoCliente)
        .replaceAll('{{nombre_asesor}}', nombreAsesor);

    _textController.text = texto;
    _textController.selection = TextSelection.fromPosition(
      TextPosition(offset: texto.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Attachment picker ─────────────────────────────────
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
              return prev.isExpirado != curr.isExpirado;
            },
            builder: (context, state) {
              final expirado = state is InfoLeadSuccess
                  ? state.isExpirado
                  : false;

              return Container(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant,
                      width: AppSizing.borderWidthSubtle,
                    ),
                  ),
                ),
                child: expirado
                    ? _ExpiradoBar(onPlantilla: _onTemplateSelected)
                    : _NormalBar(
                        textController: _textController,
                        hasText: _hasText,
                        isAttachOpen: _mode == InputMode.attachment,
                        onAttach: _toggleAttachment,
                        onPlantilla: _onTemplateSelected,
                        onSend: _sendText,
                        onMic: () {
                          widget.audioController.stop();
                          setState(() => _mode = InputMode.audio);
                        },
                      ),
              );
            },
          ),
      ],
    );
  }
}

// ── Barra normal ───────────────────────────────────────────────────────────────

class _NormalBar extends StatelessWidget {
  final TextEditingController textController;
  final bool hasText;
  final bool isAttachOpen;
  final VoidCallback onAttach;
  final VoidCallback onPlantilla;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const _NormalBar({
    required this.textController,
    required this.hasText,
    required this.isAttachOpen,
    required this.onAttach,
    required this.onPlantilla,
    required this.onSend,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // ── Botón adjuntar (cuadrado redondeado) ──────────────
        GestureDetector(
          onTap: onAttach,
          child: Container(
            width: AppSizing.buttonHeight,
            height: AppSizing.buttonHeight,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: AppSizing.hairline,
              ),
            ),
            child: Icon(
              isAttachOpen ? AppIcons.close : AppIcons.attach,
              color: colorScheme.onSurfaceVariant,
              size: AppSizing.iconMd,
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // ── Botón Plantillas (independiente) ──────────────────
        GestureDetector(
          onTap: onPlantilla,
          child: Container(
            height: AppSizing.buttonHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm2),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: AppSizing.hairline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.plantillas,
                  color: colorScheme.primary,
                  size: AppSizing.iconActionSm,
                ),
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  'Plantillas',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // ── Campo de texto + enviar ───────────────────────────
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: AppSizing.inputMaxHeight,
            ),
            child: CustomTextField(
              controller: textController,
              hint: 'Escribe un mensaje...',
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: hasText
                    ? _GreenCircleBtn(
                        key: const ValueKey('send'),
                        icon: AppIcons.send,
                        onTap: onSend,
                      )
                    : _GreenCircleBtn(
                        key: const ValueKey('mic'),
                        icon: AppIcons.mic,
                        onTap: onMic,
                      ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Barra expirada ─────────────────────────────────────────────────────────────

class _ExpiradoBar extends StatelessWidget {
  final VoidCallback onPlantilla;
  const _ExpiradoBar({required this.onPlantilla});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPlantilla,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm2,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppSizing.radiusMd),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  AppIcons.plantillas,
                  color: colorScheme.primary,
                  size: AppSizing.iconActionSm,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Plantillas',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.primary,
                    fontWeight: AppTextStyles.weightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Sesión cerrada — usa una plantilla para reabrir la conversación.',
            style: AppTextStyles.bodySmall.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Botón circular verde ───────────────────────────────────────────────────────

class _GreenCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GreenCircleBtn({super.key, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizing.buttonHeightSmall,
        height: AppSizing.buttonHeightSmall,
        decoration: BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.textOnDark,
          size: AppSizing.iconActionSm,
        ),
      ),
    );
  }
}
