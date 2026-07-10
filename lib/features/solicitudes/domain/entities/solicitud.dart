// lib/features/solicitudes/domain/entities/solicitud.dart

class Solicitud {
  final String idSolicitud;
  final String nombre;
  final String apellido;
  final String nombreEmpresa;
  final String cargo;
  final String correo;
  final String telefono;
  final String tipoPersona;
  final String idCondicionPago;
  final String condicionPago;
  final double monto;
  final String fechaCreacion;
  final int idOportunidad;
  final String oportunidad;
  final int idCanal;
  final String canal;
  final String idEstado;
  final String estado;
  final bool ibValidado;
  final String asesor;
  final String nombreAsesor;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Solicitud({
    required this.idSolicitud,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.cargo,
    required this.correo,
    required this.telefono,
    required this.tipoPersona,
    required this.idCondicionPago,
    required this.condicionPago,
    required this.monto,
    required this.fechaCreacion,
    required this.idOportunidad,
    required this.oportunidad,
    required this.idCanal,
    required this.canal,
    required this.idEstado,
    required this.estado,
    required this.ibValidado,
    required this.asesor,
    required this.nombreAsesor,
  });

  Solicitud copyWith({
    String? idSolicitud,
    String? nombre,
    String? apellido,
    String? nombreEmpresa,
    String? cargo,
    String? correo,
    String? telefono,
    String? tipoPersona,
    String? idCondicionPago,
    String? condicionPago,
    double? monto,
    String? fechaCreacion,
    int? idOportunidad,
    String? oportunidad,
    int? idCanal,
    String? canal,
    String? idEstado,
    String? estado,
    bool? ibValidado,
    String? asesor,
    String? nombreAsesor,
  }) {
    return Solicitud(
      idSolicitud: idSolicitud ?? this.idSolicitud,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      cargo: cargo ?? this.cargo,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      tipoPersona: tipoPersona ?? this.tipoPersona,
      idCondicionPago: idCondicionPago ?? this.idCondicionPago,
      condicionPago: condicionPago ?? this.condicionPago,
      monto: monto ?? this.monto,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      idOportunidad: idOportunidad ?? this.idOportunidad,
      oportunidad: oportunidad ?? this.oportunidad,
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      ibValidado: ibValidado ?? this.ibValidado,
      asesor: asesor ?? this.asesor,
      nombreAsesor: nombreAsesor ?? this.nombreAsesor,
    );
  }
}
