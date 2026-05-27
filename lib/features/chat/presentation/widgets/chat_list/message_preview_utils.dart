// lib\core\utils\ui\message_preview_utils.dart

import 'package:flutter/material.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class MessagePreview {
  final IconData? icon;
  final String label;
  final Color? color;

  const MessagePreview(this.icon, this.label, {this.color});
}

MessagePreview buildMessagePreview(Chat chat) {
  switch (chat.tipoMensaje.toLowerCase()) {
    case 'audio':
      return MessagePreview(
        Icons.mic_rounded,
        'Audio',
        color: Colors.purple.shade400,
      );
    case 'image':
      return MessagePreview(
        Icons.photo_rounded,
        'Foto',
        color: Colors.green.shade500,
      );
    case 'video':
      return MessagePreview(
        Icons.videocam_rounded,
        'Video',
        color: Colors.orange.shade400,
      );
    case 'document':
      return MessagePreview(
        fileIcon(chat.mensaje),
        fileLabel(chat.mensaje),
        color: fileColor(chat.mensaje),
      );
    case 'text':
    default:
      return MessagePreview(null, _cleanText(chat.mensaje));
  }
}

class MessageStatusIcon extends StatelessWidget {
  final String estado;
  final Color color;

  const MessageStatusIcon({
    super.key,
    required this.estado,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final dimColor = color.withOpacity(0.65);

    switch (estado) {
      case 'wait':
        return Icon(Icons.access_time_rounded, size: 12, color: dimColor);
      case 'sent':
        return Icon(Icons.check_rounded, size: 14, color: dimColor);
      case 'delivered':
        return Icon(Icons.done_all_rounded, size: 14, color: dimColor);
      case 'read':
        return Icon(
          Icons.done_all_rounded,
          size: 14,
          color: Colors.lightBlue.shade300,
        );
      case 'failed':
        return Icon(
          Icons.error_outline_rounded,
          size: 14,
          color: Colors.red.shade400,
        );
      default:
        return Icon(Icons.help_outline_rounded, size: 14, color: dimColor);
    }
  }
}

String _cleanText(String texto) {
  return texto
      .replaceAll('\\\\n', ' ') // \\n literal de la BD
      .replaceAll('\\n', ' ') // \n por si acaso
      .replaceAll('\n', ' ') // salto real
      .replaceAll('*', '') // negrita whatsapp
      .replaceAll('_', '') // cursiva whatsapp
      .replaceAll('~', '') // tachado whatsapp
      .replaceAll('`', '') // monospace whatsapp
      .replaceAll(RegExp(r' +'), ' ') // espacios dobles que quedan
      .trim();
}
