// lib/features/chat/data/models/chat_message_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.mensaje,
    required super.estado,
    required super.idMensaje,
    required super.isEnviado,
    required super.tipo,
    required super.fecha,
    required super.idChatDetArc,
    required super.nomArchivo,
    required super.extArchivo,
    required super.idChatCab,
    required super.idChatDet,
  });

  factory ChatMessageModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ChatMessageModel(
      mensaje: f(0),
      estado: f(1),
      idMensaje: f(2),
      isEnviado: f(3) == '0',
      tipo: f(4),
      fecha: f(5),
      idChatDetArc: f(6),
      nomArchivo: f(7),
      extArchivo: f(8),
      idChatCab: f(9),
      idChatDet: f(10),
    );
  }

  static List<ChatMessageModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ChatMessageModel.fromRawString(r))
        .toList();
  }
}
