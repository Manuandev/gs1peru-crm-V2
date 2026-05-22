// lib\features\chat\domain\entities\info_lead.dart

import 'package:equatable/equatable.dart';

class InfoLead extends Equatable {
  final String idLead;
  final String cliente;
  final String telefono;
  final bool isFavorito;
  final String idEstado;
  final String estado;
  final String idSubEstado;
  final String subEstado;
  final String idCampania;
  final String campania;
  final String idEvento;
  final String evento;
  final String idCanal;
  final String canal;
  final String idInteres;
  final String interes;
  final bool isBloqueado;

  const InfoLead({
    required this.idLead,
    required this.cliente,
    required this.telefono,
    required this.isFavorito,
    required this.idEstado,
    required this.estado,
    required this.idSubEstado,
    required this.subEstado,
    required this.idCampania,
    required this.campania,
    required this.idEvento,
    required this.evento,
    required this.idCanal,
    required this.canal,
    required this.idInteres,
    required this.interes,
    required this.isBloqueado,
  });

  @override
  List<Object?> get props => [
    idLead,
    cliente,
    telefono,
    isFavorito,
    idEstado,
    estado,
    idSubEstado,
    subEstado,
    idCampania,
    campania,
    idEvento,
    evento,
    idCanal,
    canal,
    idInteres,
    interes,
    isBloqueado,
  ];

  InfoLead copyWith({
    bool? isFavorito,
    bool? isBloqueado,
    String? idEstado,
    String? estado,
    String? idSubEstado,
    String? subEstado,
  }) {
    return InfoLead(
      idLead: idLead,
      cliente: cliente,
      telefono: telefono,
      isFavorito: isFavorito ?? this.isFavorito,
      idEstado: idEstado ?? this.idEstado,
      estado: estado ?? this.estado,
      idSubEstado: idSubEstado ?? this.idSubEstado,
      subEstado: subEstado ?? this.subEstado,
      idCampania: idCampania,
      campania: campania,
      idEvento: idEvento,
      evento: evento,
      idCanal: idCanal,
      canal: canal,
      idInteres: idInteres,
      interes: interes,
      isBloqueado: isBloqueado ?? this.isBloqueado,
    );
  }
}
