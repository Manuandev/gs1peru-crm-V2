// lib/features/solicitudes/domain/entities/solicitud.dart

class Solicitud {
  final String idSolicitud;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
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
  // Campaña + evento — solo los trae el task 'LSP' (paginado), para el filtro
  // del panel lateral. En una Solicitud que venga de 'LS'/'DT' quedan en 0/''.
  final int idCampania;
  final int idEvento;
  final String nombreEvento;
  final int idCanal;
  final String canal;
  final int idEstado;
  final String estado;
  final bool ibValidado;
  final String asesor;
  final String nombreAsesor;

  /// ID_LEAD del lead de origen — solo se usa al crear una solicitud NUEVA
  /// desde una negociación ganada (ContactoNegociacionCard "Generar
  /// solicitud"). Vacío en cualquier solicitud ya existente: el SP de
  /// listado ('LS') no lo trae y no hace falta para verla/editarla, solo
  /// para el INSERT inicial en CSV_SOLICITUD_CUD_APP.
  final String idLead;

  String get nombreCompleto =>
      '$nombre $apellidoPaterno $apellidoMaterno'.trim();

  String get apellidos => '$apellidoPaterno $apellidoMaterno'.trim();

  /// Editable solo mientras está "Por Completar" (`idEstado == 0`) —
  /// independiente de `ibValidado` (validar y completar son dimensiones
  /// separadas, ver `SolicitudCard._accion`). En cuanto avanza de estado
  /// deja de poder editarse, solo verse.
  bool get puedeEditar => idEstado == 0;

  const Solicitud({
    required this.idSolicitud,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
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
    this.idCampania = 0,
    this.idEvento = 0,
    this.nombreEvento = '',
    required this.idCanal,
    required this.canal,
    required this.idEstado,
    required this.estado,
    required this.ibValidado,
    required this.asesor,
    required this.nombreAsesor,
    this.idLead = '',
  });

  Solicitud copyWith({
    String? idSolicitud,
    String? nombre,
    String? apellidoPaterno,
    String? apellidoMaterno,
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
    int? idCampania,
    int? idEvento,
    String? nombreEvento,
    int? idCanal,
    String? canal,
    int? idEstado,
    String? estado,
    bool? ibValidado,
    String? asesor,
    String? nombreAsesor,
    String? idLead,
  }) {
    return Solicitud(
      idSolicitud: idSolicitud ?? this.idSolicitud,
      nombre: nombre ?? this.nombre,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
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
      idCampania: idCampania ?? this.idCampania,
      idEvento: idEvento ?? this.idEvento,
      nombreEvento: nombreEvento ?? this.nombreEvento,
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      ibValidado: ibValidado ?? this.ibValidado,
      asesor: asesor ?? this.asesor,
      nombreAsesor: nombreAsesor ?? this.nombreAsesor,
      idLead: idLead ?? this.idLead,
    );
  }
}
