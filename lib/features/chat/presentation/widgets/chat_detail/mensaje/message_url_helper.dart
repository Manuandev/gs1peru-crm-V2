// lib/features/chat/presentation/widgets/chat_detail/mensaje/message_url_helper.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class MessageUrlHelper {
  MessageUrlHelper._();

  /// URL base del archivo:
  /// https://host/archivos_wsp_gs1/{idLead}/{idConversacionCab}/archivos_adjuntos/{nombreArchivo}{tipoArchivo}
  static String buildFileUrl(ChatMessage message, int idNumero) {
    final base = EnvConfig.urlArchivos;
    final cab = message.idConversacionCab;
    final nombre = Uri.encodeComponent(message.nombreArchivo);
    final ext = Uri.encodeComponent(message.tipoArchivo);
    return '$base$idNumero/$cab/archivos_adjuntos/$nombre$ext';
  }

  /// Determina si el tipo de mensaje es una imagen
  static bool isImage(ChatMessage message) {
    final tipo = message.tipo.toLowerCase();
    final ext = message.tipoArchivo.toLowerCase().replaceAll('.', '');
    return tipo == 'image' ||
        ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(ext);
  }

  /// Determina si el tipo de mensaje es un audio
  static bool isAudio(ChatMessage message) {
    final tipo = message.tipo.toLowerCase();
    final ext = message.tipoArchivo.toLowerCase().replaceAll('.', '');
    return tipo == 'audio' ||
        ['mp3', 'm4a', 'aac', 'ogg', 'wav', 'opus'].contains(ext);
  }

  /// Determina si el tipo de mensaje es un video
  static bool isVideo(ChatMessage message) {
    final tipo = message.tipo.toLowerCase();
    final ext = message.tipoArchivo.toLowerCase().replaceAll('.', '');
    return tipo == 'video' ||
        ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  /// Determina si el tipo de mensaje es un documento
  static bool isDocument(ChatMessage message) {
    return !isImage(message) &&
        !isAudio(message) &&
        !isVideo(message) &&
        message.tipo.toLowerCase() != 'text';
  }

  /// Icono según extensión
  static String previewLabel(ChatMessage message) {
    if (isImage(message)) return '📷 Foto';
    if (isAudio(message)) return '🎵 Audio';
    if (isVideo(message)) return '🎥 Video';
    if (isDocument(message)) {
      return '📄 ${message.nombreArchivo}${message.tipoArchivo}';
    }
    return message.contenido;
  }
}
