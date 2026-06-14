// lib/features/chat/domain/entities/chat.dart

import 'package:app_crm/index_dependencies.dart';

class Chat extends Equatable {
  final int idLead;
  final String nombre;
  final String apellido;
  final String nombreEmpresa;
  final String telefono;
  final String idEstado;
  final String idMensaje;
  final String mensaje;
  final String tipoMensaje;
  final String estado;
  final String fechaHora;
  final bool isFavorito;
  final bool isEnviado;
  final int idCanal;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Chat({
    required this.idLead,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.telefono,
    required this.idEstado,
    required this.idMensaje,
    required this.mensaje,
    required this.tipoMensaje,
    required this.estado,
    required this.fechaHora,
    required this.isFavorito,
    required this.isEnviado,
    this.idCanal = 0,
  });

  @override
  List<Object?> get props => [
    idLead,
    nombre,
    apellido,
    nombreEmpresa,
    telefono,
    idEstado,
    idMensaje,
    mensaje,
    tipoMensaje,
    estado,
    fechaHora,
    isFavorito,
    isEnviado,
    idCanal,
  ];

  Chat copyWith({
    int? idLead,
    String? nombre,
    String? apellido,
    String? nombreEmpresa,
    String? telefono,
    String? idEstado,
    String? idMensaje,
    String? mensaje,
    String? tipoMensaje,
    String? estado,
    String? fechaHora,
    bool? isFavorito,
    bool? isEnviado,
    int? idCanal,
  }) {
    return Chat(
      idLead: idLead ?? this.idLead,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      telefono: telefono ?? this.telefono,
      idEstado: idEstado ?? this.idEstado,
      idMensaje: idMensaje ?? this.idMensaje,
      mensaje: mensaje ?? this.mensaje,
      tipoMensaje: tipoMensaje ?? this.tipoMensaje,
      estado: estado ?? this.estado,
      fechaHora: fechaHora ?? this.fechaHora,
      isFavorito: isFavorito ?? this.isFavorito,
      isEnviado: isEnviado ?? this.isEnviado,
      idCanal: idCanal ?? this.idCanal,
    );
  }
}
