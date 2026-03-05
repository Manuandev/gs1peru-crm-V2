// lib\features\chat\data\models\chat_message_model.dart


import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.idMensaje,
    required super.fecha,
    required super.isEnviado,
    required super.mensaje,
    required super.tipo,
    required super.estado,
    required super.nomArchivo,
    required super.extArchivo,
  });

  factory ChatMessageModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ChatMessageModel(
      idMensaje: f(0),
      fecha: f(1),
      isEnviado: f(2) == '1',
      mensaje: f(3),
      tipo: f(4),
      estado: f(5),
      nomArchivo: f(6),
      extArchivo: f(7),
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
