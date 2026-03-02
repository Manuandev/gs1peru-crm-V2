// lib\features\home\data\models\recordatorio_model.dart

import 'package:app_crm/core/constants/app_constants.dart';

class ChatItem {
  final String idLead; // 00 - ID_LEAD
  final String idChatCab; // 01 - ID_CHAT_CAB
  final String nombreApe; // 02 - B.NOMBRE + ' ' + B.APELLIDOS
  final String telefono; // 03 - TELEFONO (+51-958914300)
  final String mensaje; // 04 - MENSAJE
  final String fechaHora; // 05 - FCH_REGISTRO
  final bool isFavorito; // 06 - FLG_FAVORITO
  final bool isEnviado; // 07 - FLG_ENTRADA
  final bool isBloqueado; // 08 - LEADS_LISTA_NEGRA (bloqueado)

  const ChatItem({
    required this.idLead,
    required this.idChatCab,
    required this.nombreApe,
    required this.telefono,
    required this.mensaje,
    required this.fechaHora,
    required this.isFavorito,
    required this.isEnviado,
    required this.isBloqueado,
  });

  factory ChatItem.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ChatItem(
      idLead: f(0),
      idChatCab: f(1),
      nombreApe: f(2),
      telefono: f(3),
      mensaje: f(4),
      fechaHora: f(5),
      isFavorito: f(6) == '1',
      isEnviado: f(7) == '1',
      isBloqueado: f(8) == '1',
    );
  }

  static List<ChatItem> parseChatItemList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ChatItem.fromRawString(r))
        .toList();
  }
}

class ChatDetalle {
  final String idMensaje; // 00 - ID_MENSAJE
  final String fecha; // 01 - FCH_REGISTRO
  final bool isEnviado; // 02 - FLG_ENTRADA
  final String mensaje; // 03 - MENSAJE
  final String tipo; // 04 - TIPO_MENSAJE
  final String estado; // 05 - ESTADO
  final String nomArchivo; // 06 - ARCHIVO_NOMBRE
  final String extArchivo; // 07 - ARCHIVO_EXT
  final String abierto; // 08 - ARCHIVO_EXT

  const ChatDetalle({
    required this.idMensaje,
    required this.fecha,
    required this.isEnviado,
    required this.mensaje,
    required this.tipo,
    required this.estado,
    required this.nomArchivo,
    required this.extArchivo,
    required this.abierto,
  });

  factory ChatDetalle.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ChatDetalle(
      idMensaje: f(0),
      fecha: f(1),
      isEnviado: f(2) == '1',
      mensaje: f(3),
      tipo: f(4),
      estado: f(5),
      nomArchivo: f(6),
      extArchivo: f(7),
      abierto: f(8),
    );
  }

  static List<ChatDetalle> parseChatDetalleList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ChatDetalle.fromRawString(r))
        .toList();
  }
}
