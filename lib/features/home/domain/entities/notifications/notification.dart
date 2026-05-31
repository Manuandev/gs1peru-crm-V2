// lib/features/home/domain/entities/notification.dart

import 'package:app_crm/features/home/index_home.dart';

class Notification {
  final int totNotificaciones;
  final int totLeadsNuevos;
  final int totLeadsReasignados;
  final int totRecordatorios;

  final List<LeadNuevo> leadsNuevos;
  final List<LeadReasignado> leadsReasignados;
  final List<Recordatorio> recordatorios;

  const Notification({
    required this.totNotificaciones,
    required this.totLeadsNuevos,
    required this.totLeadsReasignados,
    required this.totRecordatorios,
    required this.leadsNuevos,
    required this.leadsReasignados,
    required this.recordatorios,
  });
}
