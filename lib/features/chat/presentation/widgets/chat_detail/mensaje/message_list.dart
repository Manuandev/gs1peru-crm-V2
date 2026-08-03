// lib/features/chat/presentation/widgets/chat_detail/mensaje/message_list.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final AudioController audioController;
  final int idNumero;
  final String nombre;
  final ChatMessage? mensajeSeleccionado;
  final void Function(ChatMessage message) onLongPressMessage;

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.audioController,
    this.isLoadingMore = false,
    required this.idNumero,
    required this.nombre,
    required this.mensajeSeleccionado,
    required this.onLongPressMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      controller: scrollController,
      // ignore: deprecated_member_use
      cacheExtent: 500.0,
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm2,
        vertical: AppSpacing.sm,
      ),
      itemCount: messages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loader al tope visual (final de la lista invertida)
        if (isLoadingMore && index == messages.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm2),
            child: Center(
              child: SizedBox(
                width: AppSizing.spinnerSizeSm,
                height: AppSizing.spinnerSizeSm,
                child: CircularProgressIndicator(
                  strokeWidth: AppSizing.spinnerStrokeSmall,
                ),
              ),
            ),
          );
        }

        // El índice 0 de la vista invertida es el último mensaje del array original.
        final messageIndex = messages.length - 1 - index;
        final message = messages[messageIndex];

        // Las fechas se evalúan respecto al orden cronológico (array original).
        final previousMessage = messageIndex > 0
            ? messages[messageIndex - 1]
            : null;

        final showDateSeparator =
            previousMessage == null ||
            !_isSameDay(message.fechaHora, previousMessage.fechaHora);

        final seleccionado =
            mensajeSeleccionado != null &&
            _mismoMensaje(mensajeSeleccionado!, message);

        return Column(
          key: ValueKey(message.idTokenMeta),
          children: [
            if (showDateSeparator) _DateSeparator(fecha: message.fechaHora),
            GestureDetector(
              onLongPress: () => onLongPressMessage(message),
              child: Container(
                width: double.infinity,
                color: seleccionado
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: AppColors.opacityActiveItem)
                    : AppColors.transparent,
                child: MessageBubble(
                  message: message,
                  audioController: audioController,
                  idNumero: idNumero,
                  nombre: nombre,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Identidad estable del mensaje — no compara por igualdad de campos
  // (Equatable) porque el estadoEntrega cambia con los checks de WhatsApp
  // y eso apagaría el resaltado de selección aunque siga siendo el mismo mensaje.
  bool _mismoMensaje(ChatMessage a, ChatMessage b) {
    if (a.idTokenMeta.isNotEmpty || b.idTokenMeta.isNotEmpty) {
      return a.idTokenMeta == b.idTokenMeta;
    }
    return a == b;
  }

  bool _isSameDay(String fecha1, String fecha2) {
    final d1 = DateFormatter.parseDate(fecha1);
    final d2 = DateFormatter.parseDate(fecha2);
    if (d1 == null || d2 == null) return true;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}

// ── Separador de fecha estilo WhatsApp ────────────────────────────────────
class _DateSeparator extends StatelessWidget {
  final String fecha;
  const _DateSeparator({required this.fecha});

  String _label() => fecha.formatDateSeparator();

  @override
  Widget build(BuildContext context) {
    final label = _label();
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm2,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSizing.radiusMd),
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.grey500,
            ),
          ),
        ),
      ),
    );
  }
}
