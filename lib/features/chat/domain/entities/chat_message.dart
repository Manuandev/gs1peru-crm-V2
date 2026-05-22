// lib\features\chat\domain\entities\chat_message.dart

import 'package:equatable/equatable.dart';

class ChatMessage extends Equatable {
  final String mensaje;
  final String estado;
  final String idMensaje;
  final bool isEnviado;
  final String tipo;
  final String fecha;
  final String idChatDetArc;
  final String nomArchivo;
  final String extArchivo;
  final String idChatCab;
  final String idChatDet;

  const ChatMessage({
    required this.mensaje,
    required this.estado,
    required this.idMensaje,
    required this.isEnviado,
    required this.tipo,
    required this.fecha,
    required this.idChatDetArc,
    required this.nomArchivo,
    required this.extArchivo,
    required this.idChatCab,
    required this.idChatDet,
  });

  @override
  List<Object?> get props => [
    mensaje,
    estado,
    idMensaje,
    isEnviado,
    tipo,
    fecha,
    idChatDetArc,
    nomArchivo,
    extArchivo,
    idChatCab,
    idChatDet,
  ];
}
