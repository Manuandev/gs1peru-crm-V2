// lib\features\chat\data\models\chat_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatModel extends Chat {
  const ChatModel({
    required super.idLead,
    required super.nombre,
    required super.apellido,
    required super.nombreEmpresa,
    required super.telefono,
    required super.idEstado,
    required super.idMensaje,
    required super.mensaje,
    required super.tipoMensaje,
    required super.estado,
    required super.fechaHora,
    required super.isFavorito,
    required super.isEnviado,
    super.idCanal = 0,
  });

  factory ChatModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ChatModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      apellido: f(2),
      nombreEmpresa: f(3),
      telefono: f(4),
      idEstado: f(5),
      idMensaje: f(6),
      mensaje: f(7),
      tipoMensaje: f(8),
      estado: f(9),
      fechaHora: f(10),
      isFavorito: f(11) == '1',
      isEnviado: f(12) == '1',
      idCanal: int.tryParse(f(13)) ?? 0,
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
