// lib\features\home\data\models\home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.totNotificaciones,
    required super.totLeadsNuevos,
    required super.totLeadsReasignados,
    required super.totRecordatorios,

    required super.leadsNuevos,
    required super.leadsReasignados,
    required super.recordatorios,
  });
  static NotificationModel parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final totalesRaw = partes.isNotEmpty ? partes[0] : '';
    final leadsNuevosRaw = partes.length > 1 ? partes[1] : '';
    final leadsReasignadosRaw = partes.length > 2 ? partes[2] : '';
    final recordatoriosRaw = partes.length > 3 ? partes[3] : '';

    final campos = totalesRaw.split(AppConstants.sepCampos);
    int t(int i) {
      if (i >= campos.length) return 0;
      final v = campos[i].trim();
      return v.isEmpty ? 0 : int.tryParse(v) ?? 0;
    }

    final leadsNuevos = leadsNuevosRaw.trim().isEmpty
        ? <LeadNuevoModel>[]
        : LeadNuevoModel.parseList(leadsNuevosRaw);

    final leadsReasignados = leadsReasignadosRaw.trim().isEmpty
        ? <LeadReasignadoModel>[]
        : LeadReasignadoModel.parseList(leadsReasignadosRaw);

    final recordatorios = recordatoriosRaw.trim().isEmpty
        ? <RecordatorioModel>[]
        : RecordatorioModel.parseList(recordatoriosRaw);

    return NotificationModel(
      totNotificaciones: t(0),
      totLeadsNuevos: t(1),
      totLeadsReasignados: t(2),
      totRecordatorios: t(3),
      leadsNuevos: leadsNuevos,
      leadsReasignados: leadsReasignados,
      recordatorios: recordatorios,
    );
  }
}
