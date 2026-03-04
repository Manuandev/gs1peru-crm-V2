// lib\features\lead\data\models\lead_detail_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetailModel extends LeadDetail {
  const LeadDetailModel({
    required super.idCreacion,
    required super.documento,
    required super.nombre,
    required super.telefono,
    required super.correo,
    required super.oportunidad,
  });

  factory LeadDetailModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return LeadDetailModel(
      idCreacion: f(0),
      documento: f(1),
      nombre: f(2),
      telefono: f(3),
      correo: f(4),
      oportunidad: f(5),
    );
  }
}
