// lib\features\home\data\models\home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.idLead,
    required super.nombre,
    required super.telefono,
    required super.oportunidad,
    required super.fechaHora,
  });

  factory NotificationModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return NotificationModel(
        idLead: int.parse(f(0)),
        nombre: f(1),
        telefono: f(2),
        oportunidad: f(3),
        fechaHora: f(4),
    );
  }

  static List<NotificationModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros) 
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NotificationModel.fromRawString(r))
        .toList();
  }
}
