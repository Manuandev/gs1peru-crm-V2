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
        AppIcons.mic,
        'Audio',
        color: AppColors.msgPreviewAudio,
      );
    case 'image':
      return MessagePreview(
        AppIcons.photo,
        'Foto',
        color: AppColors.success,
      );
    case 'video':
      return MessagePreview(
        AppIcons.videocam,
        'Video',
        color: AppColors.msgPreviewVideo,
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
    final dimColor = color.withValues(alpha: AppColors.opacityTimestamp);

    switch (estado) {
      case 'wait':
        return Icon(AppIcons.accessTime, size: AppSizing.iconStatusWait, color: dimColor);
      case 'sent':
        return Icon(AppIcons.checkSingle, size: AppSizing.iconStatus, color: dimColor);
      case 'delivered':
        return Icon(AppIcons.checkDouble, size: AppSizing.iconStatus, color: dimColor);
      case 'read':
        return Icon(
          AppIcons.checkDouble,
          size: AppSizing.iconStatus,
          color: AppColors.msgStatusRead,
        );
      case 'failed':
        return Icon(
          AppIcons.error,
          size: AppSizing.iconStatus,
          color: AppColors.errorLight,
        );
      default:
        return Icon(AppIcons.help, size: AppSizing.iconStatus, color: dimColor);
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
