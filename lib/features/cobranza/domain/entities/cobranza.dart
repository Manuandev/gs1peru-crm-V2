// lib/features/cobranza/domain/entities/cobranza.dart

class Cobranza {
  final String numSol;
  final String nombre;
  final String apellido;
  final String apellidoMaterno;
  final String nombreEmpresa;
  final String cargo;
  final String correo;
  final String tipoPersona;
  final String evento;
  final int idEvento;
  final double montoTotal;
  final String ejecutivo;
  final String asignadoA;
  final String idCondicion;
  final String condicion;
  final String fecha;
  final String? fechaVencimiento;
  final int? diasVencimiento;
  final String idEstado;
  final String estado;
  final String telefono;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Cobranza({
    required this.numSol,
    required this.nombre,
    required this.apellido,
    this.apellidoMaterno = '',
    this.nombreEmpresa = '',
    this.cargo = '',
    this.correo = '',
    this.tipoPersona = '',
    required this.evento,
    this.idEvento = 0,
    required this.montoTotal,
    required this.ejecutivo,
    required this.asignadoA,
    required this.idCondicion,
    required this.condicion,
    required this.fecha,
    this.fechaVencimiento,
    this.diasVencimiento,
    required this.idEstado,
    required this.estado,
    required this.telefono,
  });

  Cobranza copyWith({
    String? nombre,
    String? apellido,
    String? apellidoMaterno,
    String? nombreEmpresa,
    String? cargo,
    String? correo,
    String? tipoPersona,
    String? evento,
    int? idEvento,
    double? montoTotal,
    String? ejecutivo,
    String? asignadoA,
    String? idCondicion,
    String? condicion,
    String? fecha,
    String? fechaVencimiento,
    int? diasVencimiento,
    String? idEstado,
    String? estado,
    String? telefono,
  }) {
    return Cobranza(
      numSol: numSol,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      cargo: cargo ?? this.cargo,
      correo: correo ?? this.correo,
      tipoPersona: tipoPersona ?? this.tipoPersona,
      evento: evento ?? this.evento,
      idEvento: idEvento ?? this.idEvento,
      montoTotal: montoTotal ?? this.montoTotal,
      ejecutivo: ejecutivo ?? this.ejecutivo,
      asignadoA: asignadoA ?? this.asignadoA,
      idCondicion: idCondicion ?? this.idCondicion,
      condicion: condicion ?? this.condicion,
      fecha: fecha ?? this.fecha,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      diasVencimiento: diasVencimiento ?? this.diasVencimiento,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      telefono: telefono ?? this.telefono,
    );
  }
}
