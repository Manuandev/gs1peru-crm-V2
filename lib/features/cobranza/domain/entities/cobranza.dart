// lib/features/cobranza/domain/entities/cobranza.dart

class Cobranza {
  final String numSol;
  final String nombre;
  final String apellido;
  final String evento;
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
    required this.evento,
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
    String? evento,
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
      evento: evento ?? this.evento,
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
