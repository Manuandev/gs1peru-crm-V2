// lib/features/chat/presentation/widgets/chat_detail/chat_input_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatInputBar extends StatefulWidget {
  final AudioController audioController;
  // Mientras el panel de datos/negociaciones/historial está abierto, el
  // input no debe poder tomar foco — evita que el teclado se abra encima.
  final bool panelAbierto;
  // Contacto/número/estado de conversación — vienen del Chat resuelto una
  // sola vez en ChatDetailPage, no de InfoLeadCubit (que ahora es solo
  // Negociacion, sin nada de contacto/número).
  final Chat chat;

  const ChatInputBar({
    super.key,
    required this.audioController,
    required this.chat,
    this.panelAbierto = false,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  InputMode _mode = InputMode.text;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode.canRequestFocus = !widget.panelAbierto;
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void didUpdateWidget(covariant ChatInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.panelAbierto != oldWidget.panelAbierto) {
      _focusNode.canRequestFocus = !widget.panelAbierto;
      if (widget.panelAbierto) _ocultarTecladoNativo();
    }
  }

  // El unfocus() de Flutter no basta: al cerrarse el menú de los 3 puntos,
  // la restauración de foco de la ruta modal gana la carrera por un frame y
  // el teclado nativo alcanza a abrirse antes de que lo bloqueemos. Forzamos
  // el ocultamiento directo del teclado (por debajo del sistema de foco) en
  // este frame y en el siguiente, para cubrir ambos casos.
  void _ocultarTecladoNativo() {
    _focusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatDetailBloc>().add(
      ChatDetailTextMessageSent(
        text,
        numero: _getNumero(),
        idChatCab: _getChatCab(),
      ),
    );
    _textController.clear();
  }

  String _getNumero() {
    final prefijo = widget.chat.prefijoPais.replaceAll(RegExp(r'[^0-9]'), '');
    final numero = widget.chat.numero.replaceAll(RegExp(r'[^0-9]'), '');
    return '$prefijo$numero';
  }

  int _getChatCab() {
    final chatState = context.read<ChatDetailBloc>().state;
    final messages = switch (chatState) {
      ChatDetailSuccess s => s.messages,
      ChatDetailLoadingMore s => s.messages,
      _ => <ChatMessage>[],
    };
    if (messages.isEmpty) return 0;
    return messages.first.idConversacionCab;
  }

  void _onAudioReady(String path) {
    widget.audioController.stop();
    final numero = _getNumero();
    final chatCab = _getChatCab();
    context.read<ChatDetailBloc>().add(
      ChatDetailAudioMessageSent(path, numero: numero, idChatCab: chatCab),
    );
    setState(() => _mode = InputMode.text);
  }

  void _onFilesBatchPicked(List<StagedFile> files) {
    if (files.isEmpty) return;
    widget.audioController.stop();
    final numero = _getNumero();
    final chatCab = _getChatCab();
    context.read<ChatDetailBloc>().add(
      ChatDetailBatchFileMessageSent(
        files: files,
        numero: numero,
        idChatCab: chatCab,
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
    final nombreCliente = widget.chat.nombres;
    final apellidoCliente = widget.chat.apellidoPaterno ?? '';
    final isExpirado = widget.chat.isExpirado;
    final isCerrado = widget.chat.isCerrado;
    final nombreAsesor = SessionService().userApe;

    final plantilla = await SelectTemplateModal.show(
      context,
      nombreCliente: nombreCliente,
      apellidoCliente: apellidoCliente,
      nombreAsesor: nombreAsesor,
    );
    if (plantilla == null || !mounted) return;

    context.read<ChatDetailBloc>().add(
      ChatDetailTemplateMessageSent(
        template: plantilla,
        numero: _getNumero(),
        idChatCab: _getChatCab(),
        nombreCliente: nombreCliente,
        apellidoCliente: apellidoCliente,
        isExpirado: isExpirado,
        isCerrado: isCerrado,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Con el panel de datos/negociaciones/historial abierto, toda la barra
    // queda bloqueada al toque — no solo el foco del input.
    return IgnorePointer(
      ignoring: widget.panelAbierto,
      child: Column(
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
            Container(
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
              child: widget.chat.isExpirado
                  ? _ExpiradoBar(onPlantilla: _onTemplateSelected)
                  : _NormalBar(
                      textController: _textController,
                      focusNode: _focusNode,
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
            ),
        ],
      ),
    );
  }
}

// ── Barra normal ───────────────────────────────────────────────────────────────

class _NormalBar extends StatelessWidget {
  final TextEditingController textController;
  final FocusNode focusNode;
  final bool hasText;
  final bool isAttachOpen;
  final VoidCallback onAttach;
  final VoidCallback onPlantilla;
  final VoidCallback onSend;
  final VoidCallback onMic;

  const _NormalBar({
    required this.textController,
    required this.focusNode,
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
              focusNode: focusNode,
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
