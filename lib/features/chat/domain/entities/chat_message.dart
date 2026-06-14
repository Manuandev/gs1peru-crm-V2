// lib/features/chat/domain/entities/chat_message.dart

import 'package:app_crm/index_dependencies.dart';

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

  ChatMessage copyWith({
    String? mensaje,
    String? estado,
    String? idMensaje,
    bool? isEnviado,
    String? tipo,
    String? fecha,
    String? idChatDetArc,
    String? nomArchivo,
    String? extArchivo,
    String? idChatCab,
    String? idChatDet,
  }) {
    return ChatMessage(
      mensaje: mensaje ?? this.mensaje,
      estado: estado ?? this.estado,
      idMensaje: idMensaje ?? this.idMensaje,
      isEnviado: isEnviado ?? this.isEnviado,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      idChatDetArc: idChatDetArc ?? this.idChatDetArc,
      nomArchivo: nomArchivo ?? this.nomArchivo,
      extArchivo: extArchivo ?? this.extArchivo,
      idChatCab: idChatCab ?? this.idChatCab,
      idChatDet: idChatDet ?? this.idChatDet,
    );
  }
}
