// lib\features\lead\domain\entities\prospecto.dart

import 'package:app_crm/features/lead/index_lead.dart';

class Prospecto extends LeadEntity {
  @override
  final int idLead;
  @override
  final String nombre;
  @override
  final String apellido;
  @override
  final String nombreEmpresa;
  @override
  final String telefono;
  @override
  final bool isFavorito;
  @override
  final String asignadoA;
  @override
  final String idEstado;
  @override
  final String estado;
  @override
  final int? idEvento;
  @override
  final String? evento;
  @override
  final int? idCampania;
  @override
  final String? campania;
  @override
  final int? idCanal;
  @override
  final String? canal;
  @override
  final int? idInteres;
  @override
  final String? interes;
  @override
  final String fechaHora;

  @override
  String get nombreCompleto => '$nombre $apellido'.trim();

  const Prospecto({
    required this.idLead,
    required this.nombre,
    required this.apellido,
    required this.nombreEmpresa,
    required this.telefono,
    required this.isFavorito,
    required this.asignadoA,
    required this.idEstado,
    required this.estado,
    required this.idCampania,
    required this.campania,
    required this.idEvento,
    required this.evento,
    required this.idCanal,
    required this.canal,
    required this.idInteres,
    required this.interes,
    required this.fechaHora,
  });

  @override
  LeadEntity copyWith({
    int? idLead,
    String? nombre,
    String? apellido,
    String? nombreEmpresa,
    String? telefono,
    bool? isFavorito,
    String? asignadoA,
    String? idEstado,
    String? estado,
    int? idEvento,
    String? evento,
    int? idCampania,
    String? campania,
    int? idCanal,
    String? canal,
    int? idInteres,
    String? interes,
    String? fechaHora,
  }) {
    return Prospecto(
      idLead: idLead ?? this.idLead,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      nombreEmpresa: nombreEmpresa ?? this.nombreEmpresa,
      telefono: telefono ?? this.telefono,
      isFavorito: isFavorito ?? this.isFavorito,
      asignadoA: asignadoA ?? this.asignadoA,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      idEvento: idEvento ?? this.idEvento,
      evento: evento ?? this.evento,
      idCampania: idCampania ?? this.idCampania,
      campania: campania ?? this.campania,
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      idInteres: idInteres ?? this.idInteres,
      interes: interes ?? this.interes,
      fechaHora: fechaHora ?? this.fechaHora,
    );
  }
}
