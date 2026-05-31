// lib/features/home/domain/entities/notification.dart

import 'package:app_crm/features/home/index_home.dart';

class Notification {
  final int totNotificaciones;
  final int totLeadsReasignados;
  final int totLeadsNuevos;
  final int totRecordatorios;

  final List<LeadReasignado> leadsReasignados;
  final List<LeadNuevo> leadsNuevos;
  final List<Recordatorio> recordatorios;

  const Notification({
    required this.totNotificaciones,
    required this.totLeadsReasignados,
    required this.totLeadsNuevos,
    required this.totRecordatorios,
    required this.leadsReasignados,
    required this.leadsNuevos,
    required this.recordatorios,
  });
}
