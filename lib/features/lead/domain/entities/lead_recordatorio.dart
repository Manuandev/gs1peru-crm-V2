// lib/features/lead/domain/entities/lead_recordatorio.dart

import 'package:app_crm/index_dependencies.dart';

/// Recordatorio de seguimiento (CRM.T_LEAD_RECORDATORIO) — viene del SP
/// 'LRN' (todos los recordatorios futuros de los leads del mismo contacto,
/// ordenados por fecha ascendente — el SP ya filtra GETDATE() <=
/// FC_RECORDATORIO, así que aquí nunca llega uno vencido).
class LeadRecordatorio extends Equatable {
  final int idRecordatorio;
  final int idLead;
  final int idContacto;
  final String fechaRecordatorio;
  final String comentario;
  final String campania;
  final String oportunidad;
  final String avisoDescripcion;
  final int avisoMinutos;
  final String accionDescripcion;
  // Código crudo (CODUSER) de quien creó el recordatorio — se resuelve a
  // nombre real en la UI vía CatalogsBloc.asesores, nunca a un badge de rol
  // (a diferencia de HistorialComentario.tipoActor/actorLabel).
  final String idUsuarioC;

  const LeadRecordatorio({
    required this.idRecordatorio,
    required this.idLead,
    required this.idContacto,
    required this.fechaRecordatorio,
    required this.comentario,
    required this.campania,
    required this.oportunidad,
    required this.avisoDescripcion,
    required this.avisoMinutos,
    required this.accionDescripcion,
    required this.idUsuarioC,
  });

  @override
  List<Object?> get props => [
    idRecordatorio,
    idLead,
    idContacto,
    fechaRecordatorio,
    comentario,
    campania,
    oportunidad,
    avisoDescripcion,
    avisoMinutos,
    accionDescripcion,
    idUsuarioC,
  ];
}
