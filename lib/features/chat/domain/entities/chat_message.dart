// lib\features\chat\domain\entities\chat_message.dart

import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String idMensaje; // 00 - ID_MENSAJE
  final String fecha; // 01 - FCH_REGISTRO
  final bool isEnviado; // 02 - FLG_ENTRADA
  final String mensaje; // 03 - MENSAJE
  final String tipo; // 04 - TIPO_MENSAJE
  final String estado; // 05 - ESTADO
  final String idChatDetArc; // 06 - ID_CHAT_DET_ARCHIVO
  final String nomArchivo; // 07 - ARCHIVO_NOMBRE
  final String extArchivo; // 08 - ARCHIVO_EXT
  final String idChatCab; // 09 - ID_CHAT_CAB
  final String idChatDet; // 10 - ID_CHAT_DET

  const ChatMessage({
    required this.idMensaje,
    required this.fecha,
    required this.isEnviado,
    required this.mensaje,
    required this.tipo,
    required this.estado,
    required this.idChatDetArc,
    required this.nomArchivo,
    required this.extArchivo,
    required this.idChatCab,
    required this.idChatDet,
  });

  @override
  List<Object?> get props => [
    idMensaje,
    fecha,
    isEnviado,
    mensaje,
    tipo,
    estado,
    idChatDetArc,
    nomArchivo,
    extArchivo,
    idChatCab,
    idChatDet,
  ];
}
