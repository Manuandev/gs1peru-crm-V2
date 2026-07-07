// lib/features/lead/domain/entities/negociacion_lead.dart

import 'package:app_crm/index_dependencies.dart';

class Negociacion extends Equatable {
  final int idLead;

  final String nombre;
  final String modalidad;

  final int cantidad;
  final double precioBase;
  final double descuento;
  final double precio;
  final String fechaHoraInteraccion;
  final String fechaHoraCreacion;

  final String idEstado;
  final String descripcionEstado;

  final String idEstadoPadre;
  final String descripcionEstadoPadre;

  final int idCampania;
  final String nombreCampania;

  final int idOportunidad;
  final String nombreOportunidad;

  final int idCanal;
  final String descripcionCanal;

  final int idInteres;
  final String descripcionInteres;

  final bool activo;

  // Contacto/número — de solo lectura en el form de edición. Con default
  // porque no todos los SPs que alimentan Negociacion los traen (ej. 'LN' —
  // historial de negociaciones). Se completan desde el SP de detalle ('DT')
  // o desde el Chat ya cargado en lista.
  final int idNumero;
  final String prefijoPais;
  final String numero;
  final String nombres;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String nombreEmpresa;
  final String correo;

  /// Id de estado a mostrar/agrupar: si hay un sub-estado (idEstadoPadre
  /// presente), se usa el padre — ej. "Con ficha" agrupa bajo "En desarrollo".
  String get idEstadoEfectivo =>
      idEstadoPadre.isNotEmpty ? idEstadoPadre : idEstado;

  /// Descripción de estado a mostrar — misma regla que [idEstadoEfectivo].
  String get estadoEfectivo => idEstadoPadre.isNotEmpty
      ? (descripcionEstadoPadre.isNotEmpty
            ? descripcionEstadoPadre
            : descripcionEstado)
      : descripcionEstado;

  const Negociacion({
    required this.idLead,
    required this.nombre,
    required this.modalidad,
    required this.cantidad,
    required this.precioBase,
    required this.descuento,
    required this.precio,
    required this.fechaHoraInteraccion,
    required this.fechaHoraCreacion,
    required this.idEstado,
    required this.descripcionEstado,
    required this.idEstadoPadre,
    required this.descripcionEstadoPadre,
    required this.idCampania,
    required this.nombreCampania,
    required this.idOportunidad,
    required this.nombreOportunidad,
    required this.idCanal,
    required this.descripcionCanal,
    required this.idInteres,
    required this.descripcionInteres,
    required this.activo,
    this.idNumero = 0,
    this.prefijoPais = '',
    this.numero = '',
    this.nombres = '',
    this.apellidoPaterno = '',
    this.apellidoMaterno = '',
    this.nombreEmpresa = '',
    this.correo = '',
  });

  @override
  List<Object?> get props => [
    idLead,
    nombre,
    modalidad,
    cantidad,
    precioBase,
    descuento,
    precio,
    fechaHoraInteraccion,
    fechaHoraCreacion,
    idEstado,
    descripcionEstado,
    idEstadoPadre,
    descripcionEstadoPadre,
    idCampania,
    nombreCampania,
    idOportunidad,
    nombreOportunidad,
    idCanal,
    descripcionCanal,
    idInteres,
    descripcionInteres,
    activo,
    idNumero,
    prefijoPais,
    numero,
    nombres,
    apellidoPaterno,
    apellidoMaterno,
    nombreEmpresa,
    correo,
  ];

  Negociacion copyWith({
    int? idLead,
    String? nombre,
    String? modalidad,
    int? cantidad,
    double? precioBase,
    double? descuento,
    double? precio,
    String? fechaHoraInteraccion,
    String? fechaHoraCreacion,
    String? idEstado,
    String? descripcionEstado,
    String? idEstadoPadre,
    String? descripcionEstadoPadre,
    int? idCampania,
    String? nombreCampania,
    int? idOportunidad,
    String? nombreOportunidad,
    int? idCanal,
    String? descripcionCanal,
    int? idInteres,
    String? descripcionInteres,
    bool? activo,
    int? idNumero,
    String? prefijoPais,
    String? numero,
    String? nombres,
    String? apellidoPaterno,
    String? apellidoMaterno,
    String? nombreEmpresa,
    String? correo,
  }) {
    return Negociacion(
      idLead: idLead ?? this.idLead,
      nombre: nombre ?? this.nombre,
      modalidad: modalidad ?? this.modalidad,
      cantidad: cantidad ?? this.cantidad,
      precioBase: precioBase ?? this.precioBase,
      descuento: descuento ?? this.descuento,
      precio: precio ?? this.precio,
      fechaHoraInteraccion: fechaHoraInteraccion ?? this.fechaHoraInteraccion,
      fechaHoraCreacion: fechaHoraCreacion ?? this.fechaHoraCreacion,
      idEstado: idEstado ?? this.idEstado,
      descripcionEstado: descripcionEstado ?? this.descripcionEstado,
      idEstadoPadre: idEstadoPadre ?? this.idEstadoPadre,
      descripcionEstadoPadre:
          descripcionEstadoPadre ?? this.descripcionEstadoPadre,
      idCampania: idCampania ?? this.idCampania,
      nombreCampania: nombreCampania ?? this.nombreCampania,
      idOportunidad: idOportunidad ?? this.idOportunidad,
      nombreOportunidad: nombreOportunidad ?? this.nombreOportunidad,
      idCanal: idCanal ?? this.idCanal,
      descripcionCanal: descripcionCanal ?? this.descripcionCanal,
      idInteres: idInteres ?? this.idInteres,
      descripcionInteres: descripcionInteres ?? this.descripcionInteres,
      activo: activo ?? this.activo,
      idNumero: idNumero ?? this.idNumero,
      prefijoPais: prefijoPais ?? this.prefijoPais,
      numero: numero ?? this.numero,
      nombres: nombres ?? this.nombres,
      apellidoPaterno: apellidoPaterno ?? this.apellidoPaterno,
      apellidoMaterno: apellidoMaterno ?? this.apellidoMaterno,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      correo: correo ?? this.correo,
    );
  }
}

extension NegociacionesX on List<Negociacion> {
  Negociacion? get primerLead {
    if (isEmpty) return null;
    final ordenadas = [...this]
      ..sort((a, b) => a.fechaHoraCreacion.compareTo(b.fechaHoraCreacion));
    return ordenadas.first;
  }

  /// La negociación con la actividad más reciente (por fecha de última
  /// interacción) — alimenta el campo "Última interacción".
  Negociacion? get ultimaInteraccion {
    if (isEmpty) return null;
    final ordenadas = [
      ...this,
    ]..sort((a, b) => b.fechaHoraInteraccion.compareTo(a.fechaHoraInteraccion));
    return ordenadas.first;
  }
}
