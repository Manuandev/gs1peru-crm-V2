// lib\features\chat\presentation\widgets\chat_detail\message_list.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final AudioController audioController;
  final String idLead; // ← agregar

  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    required this.audioController,
    this.isLoadingMore = false,
    required this.idLead,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loader al tope cuando se pagina
        if (isLoadingMore && index == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final messageIndex = isLoadingMore ? index - 1 : index;
        final message = messages[messageIndex];
        final previousMessage = messageIndex > 0
            ? messages[messageIndex - 1]
            : null;

        final showDateSeparator =
            previousMessage == null ||
            !_isSameDay(message.fecha, previousMessage.fecha);

        return Column(
          children: [
            if (showDateSeparator) _DateSeparator(fecha: message.fecha),
            MessageBubble(
              message: message,
              audioController: audioController,
              idLead: idLead,
            ),
          ],
        );
      },
    );
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

  // Mismo patrón que ChatTile._formatFecha
  String _label() {
    if (fecha.isEmpty) return '';
    final date = DateFormatter.parseDate(fecha);
    if (date == null) return '';

    final ahora = DateTime.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);
    final diaFecha = DateTime(date.year, date.month, date.day);
    final diferencia = hoy.difference(diaFecha).inDays;

    if (diferencia == 0) return 'Hoy';
    if (diferencia == 1) return 'Ayer';
    if (diferencia < 7) return fecha.formatDate(AppDateFormat.weekdayOnly);
    return fecha.formatDate(AppDateFormat.shortDate);
  }

  @override
  Widget build(BuildContext context) {
    final label = _label();
    if (label.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
