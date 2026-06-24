// lib/features/solicitudes/domain/entities/solicitud.dart

class Solicitud {
  final int idSolicitud;
  final int idContacto;
  final String nombre;
  final String apellido;
  final String nombreEmpresa;
  final String correo;
  final String telefono;
  final int idTipoSolicitud;
  final String tipoSolicitud;
  final String idEstado;
  final String estado;
  final String asesor;
  final String nombreAsesor;
  final int idCanal;
  final String fechaCreacion;
  final double monto;
  final String observaciones;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Solicitud({
    required this.idSolicitud,
    required this.idContacto,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.correo,
    required this.telefono,
    required this.idTipoSolicitud,
    required this.tipoSolicitud,
    required this.idEstado,
    required this.estado,
    required this.asesor,
    required this.nombreAsesor,
    required this.idCanal,
    required this.fechaCreacion,
    required this.monto,
    required this.observaciones,
  });

  Solicitud copyWith({
    int? idSolicitud,
    int? idContacto,
    String? nombre,
    String? apellido,
    String? nombreEmpresa,
    String? correo,
    String? telefono,
    int? idTipoSolicitud,
    String? tipoSolicitud,
    String? idEstado,
    String? estado,
    String? asesor,
    String? nombreAsesor,
    int? idCanal,
    String? fechaCreacion,
    double? monto,
    String? observaciones,
  }) {
    return Solicitud(
      idSolicitud: idSolicitud ?? this.idSolicitud,
      idContacto: idContacto ?? this.idContacto,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      idTipoSolicitud: idTipoSolicitud ?? this.idTipoSolicitud,
      tipoSolicitud: tipoSolicitud ?? this.tipoSolicitud,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      asesor: asesor ?? this.asesor,
      nombreAsesor: nombreAsesor ?? this.nombreAsesor,
      idCanal: idCanal ?? this.idCanal,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      monto: monto ?? this.monto,
      observaciones: observaciones ?? this.observaciones,
    );
  }
}
