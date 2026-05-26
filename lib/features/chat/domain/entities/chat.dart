// lib\features\chat\domain\entities\chat.dart

import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final int idLead; // 00 - ID_LEAD
  final String nombreApe; // 01 - B.NOMBRE + ' ' + B.APELLIDOS
  final String telefono; // 02 - TELEFONO (+51-958914300)
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
    mensaje,
    tipoMensaje,
    estado,
    fechaHora,
    isFavorito,
    isEnviado,
  ];
}
