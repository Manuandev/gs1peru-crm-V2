// lib\features\chat\data\models\chat_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required super.idLead,
    required super.nombreApe,
    required super.telefono,
    required super.mensaje,
    required super.tipoMensaje,
    required super.estado,
    required super.fechaHora,
    required super.isFavorito,
    required super.isEnviado,
  });

  factory ChatModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ChatModel(
      idLead: f(0),
      nombreApe: f(1),
      telefono: f(2),
      mensaje: f(3),
      tipoMensaje: f(4),
      estado: f(5),
      fechaHora: f(6),
      isFavorito: f(7) == '1',
      isEnviado: f(8) == '1',
    );
  }

  static List<ChatModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ChatModel.fromRawString(r))
        .toList();
  }
}
