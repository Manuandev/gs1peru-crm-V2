// lib/features/chat/data/models/message_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.idConversacionCab,
    required super.idConversacionDet,
    required super.idTokenMeta,
    required super.direccionMensaje,
    required super.tipo,
    required super.contenido,
    required super.estadoEntrega,
    required super.fechaHora,
    required super.rutaArchivo,
    required super.tipoArchivo,
    required super.nombreArchivo,
  });

  factory ChatMessageModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return ChatMessageModel(
      idConversacionCab: ParseUtils.toInt(fields, 0),
      idConversacionDet: ParseUtils.toInt(fields, 1),
      idTokenMeta: ParseUtils.str(fields, 2),
      direccionMensaje: ParseUtils.str(fields, 3),
      tipo: ParseUtils.str(fields, 4),
      contenido: ParseUtils.str(fields, 5),
      estadoEntrega: ParseUtils.str(fields, 6),
      fechaHora: ParseUtils.str(fields, 7),
      rutaArchivo: ParseUtils.str(fields, 8),
      tipoArchivo: ParseUtils.str(fields, 9),
      nombreArchivo: ParseUtils.str(fields, 10),
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
