// lib\features\chat\domain\entities\chat.dart

import 'package:app_crm/index_dependencies.dart';

class Chat extends Equatable {
  final int idLead; // 00 - ID_LEAD
  final String nombreApe; // 01 - B.NOMBRE + ' ' + B.APELLIDOS
  final String telefono; // 02 - TELEFONO (+51-958914300)
  final String idMensaje; // 03 - MENSAJE
  final String mensaje; // 03 - MENSAJE
  final String tipoMensaje; // 04 - TIPO_MENSAJE (E/S)
  final String estado; // 05 - ESTADO (LEIDO/NO_LEIDO)
  final String fechaHora; // 06 - FCH_REGISTRO
  final bool isFavorito; // 07 - FLG_FAVORITO
  final bool isEnviado; // 08 - FLG_ENTRADA

  const Chat({
    required this.idLead,
    required this.nombreApe,
    required this.telefono,
    required this.idMensaje,
    required this.mensaje,
    required this.tipoMensaje,
    required this.estado,
    required this.fechaHora,
    required this.isFavorito,
    required this.isEnviado,
  });

  @override
  List<Object?> get props => [
    idLead,
    nombreApe,
    telefono,
    idMensaje,
    mensaje,
    tipoMensaje,
    estado,
    fechaHora,
    isFavorito,
    isEnviado,
  ];

  Chat copyWith({
    int? idLead,
    String? nombreApe,
    String? telefono,
    String? idMensaje,
    String? mensaje,
    String? tipoMensaje,
    String? estado,
    String? fechaHora,
    bool? isFavorito,
    bool? isEnviado,
  }) {
    return Chat(
      idLead: idLead ?? this.idLead,
      nombreApe: nombreApe ?? this.nombreApe,
      telefono: telefono ?? this.telefono,
      idMensaje: idMensaje ?? this.idMensaje,
      mensaje: mensaje ?? this.mensaje,
      tipoMensaje: tipoMensaje ?? this.tipoMensaje,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
      isFavorito: isFavorito ?? this.isFavorito,
      isEnviado: isEnviado ?? this.isEnviado,
    );
  }
}
