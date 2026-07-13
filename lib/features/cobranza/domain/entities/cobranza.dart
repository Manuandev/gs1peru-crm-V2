// lib/features/cobranza/domain/entities/cobranza.dart

class Cobranza {
  final String numSol;

  // Datos del contacto
  final String nombre;
  final String apellido;
  final String apellidoMaterno;
  final String nombreEmpresa;
  final String cargo;
  final String telefono;
  final String correo;

  // Tipo de persona — codTipoPersona: 'J'/'N' crudo · tipoPersona: label ('Juridica'/'Natural')
  final String codTipoPersona;
  final String tipoPersona;

  final String fecha;
  final double montoTotal;

  // Condición de pago
  final String idCondicion;
  final String condicion;

  final String ejecutivo;

  // Oportunidad/evento asociado
  final int idEvento;
  final String evento;

  // Estado de gestión de cobranza — ver DBO.[edu.TIP_ESTADO_GES] (0=Pend.deDocumento
  // 1=FreePass 2=Facturar 3=Cancelado 4=Anulado 5=Pend.factura). idEstado es el código
  // interno de la app (PD/FP/F/CA/AN/PP) traducido en CobranzaModel; estado es la
  // descripción tal cual la manda el backend.
  final int idEstado;
  final String estado;
  final bool ibValidado;

  final String asignadoA;

  // Solo disponibles en el detalle (el SP de lista aún no los trae)
  final String? fechaVencimiento;
  final int? diasVencimiento;

  String get nombreCompleto => '$nombre $apellido'.trim();

  const Cobranza({
    required this.numSol,
    required this.nombre,
    required this.apellido,
    this.apellidoMaterno = '',
    this.nombreEmpresa = '',
    this.cargo = '',
    required this.telefono,
    this.correo = '',
    this.codTipoPersona = '',
    this.tipoPersona = '',
    required this.fecha,
    required this.montoTotal,
    required this.idCondicion,
    required this.condicion,
    required this.ejecutivo,
    this.idEvento = 0,
    required this.evento,
    required this.idEstado,
    required this.estado,
    this.ibValidado = true,
    required this.asignadoA,
    this.fechaVencimiento,
    this.diasVencimiento,
  });

  Cobranza copyWith({
    String? nombre,
    String? apellido,
    String? apellidoMaterno,
    String? nombreEmpresa,
    String? cargo,
    String? telefono,
    String? correo,
    String? codTipoPersona,
    String? tipoPersona,
    String? fecha,
    double? montoTotal,
    String? idCondicion,
    String? condicion,
    String? ejecutivo,
    int? idEvento,
    String? evento,
    int? idEstado,
    String? estado,
    bool? ibValidado,
    String? asignadoA,
    String? fechaVencimiento,
    int? diasVencimiento,
  }) {
    return Cobranza(
      numSol: numSol,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      cargo: cargo ?? this.cargo,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      codTipoPersona: codTipoPersona ?? this.codTipoPersona,
      tipoPersona: tipoPersona ?? this.tipoPersona,
      fecha: fecha ?? this.fecha,
      montoTotal: montoTotal ?? this.montoTotal,
      idCondicion: idCondicion ?? this.idCondicion,
      condicion: condicion ?? this.condicion,
      ejecutivo: ejecutivo ?? this.ejecutivo,
      idEvento: idEvento ?? this.idEvento,
      evento: evento ?? this.evento,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      ibValidado: ibValidado ?? this.ibValidado,
      asignadoA: asignadoA ?? this.asignadoA,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      diasVencimiento: diasVencimiento ?? this.diasVencimiento,
    );
  }
}
