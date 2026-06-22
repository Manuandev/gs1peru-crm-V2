// lib/features/chat/domain/entities/message.dart

import 'package:app_crm/index_dependencies.dart';

class ChatMessage extends Equatable {
  // Detalle mensaje
  final int idConversacionCab;
  final int idConversacionDet;
  final String idTokenMeta;
  final String direccionMensaje; // AIA - ASISTENTE IA  / ASE - ASESOR / CLI - CLIENTE
  final String tipo;
  final String contenido;
  final String estadoEntrega;
  final String fechaHora;
  // Documento si tiene
  final String rutaArchivo;
  final String tipoArchivo;
  final String nombreArchivo;

  const ChatMessage({
    required this.idConversacionCab,
    required this.idConversacionDet,
    required this.idTokenMeta,
    required this.direccionMensaje,
    required this.tipo,
    required this.contenido,
    required this.estadoEntrega,
    required this.fechaHora,
    required this.rutaArchivo,
    required this.tipoArchivo,
    required this.nombreArchivo,
  });

  @override
  List<Object?> get props => [
    idConversacionCab,
    idConversacionDet,
    idTokenMeta,
    direccionMensaje,
    tipo,
    contenido,
    estadoEntrega,
    fechaHora,
    rutaArchivo,
    tipoArchivo,
    nombreArchivo,
  ];

  ChatMessage copyWith({
    int? idConversacionCab,
    int? idConversacionDet,
    String? idTokenMeta,
    String? direccionMensaje,
    String? tipo,
    String? contenido,
    String? estadoEntrega,
    String? fechaHora,
    String? rutaArchivo,
    String? tipoArchivo,
    String? nombreArchivo,
  }) {
    return ChatMessage(
      idConversacionCab: idConversacionCab ?? this.idConversacionCab,
      idConversacionDet: idConversacionDet ?? this.idConversacionDet,
      idTokenMeta: idTokenMeta ?? this.idTokenMeta,
      direccionMensaje: direccionMensaje ?? this.direccionMensaje,
      tipo: tipo ?? this.tipo,
      contenido: contenido ?? this.contenido,
      estadoEntrega: estadoEntrega ?? this.estadoEntrega,
      fechaHora: fechaHora ?? this.fechaHora,
      rutaArchivo: rutaArchivo ?? this.rutaArchivo,
      tipoArchivo: tipoArchivo ?? this.tipoArchivo,
      nombreArchivo: nombreArchivo ?? this.nombreArchivo,
    );
  }
}
