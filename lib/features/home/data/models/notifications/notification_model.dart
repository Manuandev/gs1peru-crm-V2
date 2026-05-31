// lib\features\home\data\models\home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.totNotificaciones,
    required super.totLeadsReasignados,
    required super.totLeadsNuevos,
    required super.totRecordatorios,

    required super.leadsReasignados,
    required super.leadsNuevos,
    required super.recordatorios,
  });
  static NotificationModel parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final totalesRaw = partes.isNotEmpty ? partes[0] : '';
    final leadsReasignadosRaw = partes.length > 1 ? partes[1] : '';
    final leadsNuevosRaw = partes.length > 2 ? partes[2] : '';
    final recordatoriosRaw = partes.length > 3 ? partes[3] : '';

    final campos = totalesRaw.split(AppConstants.sepCampos);
    int t(int i) {
      if (i >= campos.length) return 0;
      final v = campos[i].trim();
      return v.isEmpty ? 0 : int.tryParse(v) ?? 0;
    }

    final leadsReasignados = leadsReasignadosRaw.trim().isEmpty
        ? <LeadReasignadoModel>[]
        : LeadReasignadoModel.parseList(leadsReasignadosRaw);

    final leadsNuevos = leadsNuevosRaw.trim().isEmpty
        ? <LeadNuevoModel>[]
        : LeadNuevoModel.parseList(leadsNuevosRaw);

    final recordatorios = recordatoriosRaw.trim().isEmpty
        ? <RecordatorioModel>[]
        : RecordatorioModel.parseList(recordatoriosRaw);

    return NotificationModel(
      totNotificaciones: t(0),
      totLeadsReasignados: t(1),
      totLeadsNuevos: t(2),
      totRecordatorios: t(3),
      leadsReasignados: leadsReasignados,
      leadsNuevos: leadsNuevos,
      recordatorios: recordatorios,
    );
  }
}
