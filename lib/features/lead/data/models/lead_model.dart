// lib\features\lead\data\models\lead_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadModel extends Lead {
  const LeadModel({
    required super.userCreacion,
    required super.idLead,
    required super.fecha,
    required super.dia,
    required super.numDia,
    required super.mes,
    required super.anho,
    required super.hora,
    required super.dni,
  });

  factory LeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return LeadModel(
      userCreacion: f(0),
      idLead: f(1),
      fecha: f(2),
      dia: f(3),
      numDia: f(4),
      mes: f(5),
      anho: f(6),
      hora: f(7),
      dni: f(8),
    );
  }

  static List<LeadModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros) // '¬' separa cada lead
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadModel.fromRawString(r))
        .toList();
  }
}
