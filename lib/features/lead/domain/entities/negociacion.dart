// lib/features/lead/domain/entities/negociacion_lead.dart

import 'package:app_crm/index_dependencies.dart';

class Negociacion extends Equatable {
  final int idLead;
  final int cantidad;
  final double descuento;

  final double precioBase;
  final double precio;
  final String fechaHora;
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

  const Negociacion({
    required this.idLead,
    required this.cantidad,
    required this.descuento,
    required this.precioBase,
    required this.precio,
    required this.fechaHora,
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
  });

  @override
  List<Object?> get props => [
    idLead,
    cantidad,
    descuento,
    precioBase,
    precio,
    fechaHora,
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
  ];

  Negociacion copyWith({
    int? idLead,
    int? cantidad,
    double? descuento,
    double? precioBase,
    double? precio,
    String? fechaHora,
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
  }) {
    return Negociacion(
      idLead: idLead ?? this.idLead,
      cantidad: cantidad ?? this.cantidad,
      descuento: descuento ?? this.descuento,
      precioBase: precioBase ?? this.precioBase,
      precio: precio ?? this.precio,
      fechaHora: fechaHora ?? this.fechaHora,
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
    );
  }
}

/// Helpers sobre una lista de negociaciones de un mismo contacto.
extension NegociacionesX on List<Negociacion> {
  /// La negociación más antigua (por fecha de creación) — el "primer lead"
  /// del contacto. Sus campos (estado, canal, campaña, oportunidad) son los
  /// que se muestran en el stepper y en la pestaña de Información.
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
    final ordenadas = [...this]
      ..sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    return ordenadas.first;
  }
}
