// lib\features\chat\domain\entities\info_lead.dart

import 'package:app_crm/index_dependencies.dart';

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
  final bool isExpirado;
  final bool isCerrado;

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
    required this.isExpirado,
    required this.isCerrado,
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
    isExpirado,
    isCerrado,
  ];

  InfoLead copyWith({
    bool? isFavorito,
    String? idEstado,
    String? estado,
    String? idSubEstado,
    String? subEstado,
    String? idCampania,
    String? campania,
    String? idEvento,
    String? evento,
    String? idCanal,
    String? canal,
    String? idInteres,
    String? interes,
    bool? isBloqueado,
    bool? isExpirado,
    bool? isCerrado,
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
      idCampania: idCampania ?? this.idCampania,
      campania: campania ?? this.campania,
      idEvento: idEvento ?? this.idEvento,
      evento: evento ?? this.evento,
      idCanal: idCanal ?? this.idCanal,
      canal: canal ?? this.canal,
      idInteres: idInteres ?? this.idInteres,
      interes: interes ?? this.interes,
      isBloqueado: isBloqueado ?? this.isBloqueado,
      isExpirado: isExpirado ?? this.isExpirado,
      isCerrado: isCerrado ?? this.isCerrado,
    );
  }
}
