// lib/features/lead/domain/entities/comentario_lead.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ComentarioLeadModel extends ComentarioLead {
  const ComentarioLeadModel({
    required super.id,
    required super.autor,
    required super.texto,
    required super.actividad,
    required super.fechaHora,
  });

  factory ComentarioLeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return ComentarioLeadModel(
      id: ParseUtils.toInt(fields, 0),
      autor: ParseUtils.str(fields, 1),
      texto: ParseUtils.str(fields, 2),
      actividad: ParseUtils.str(fields, 3),
      fechaHora: ParseUtils.str(fields, 4),
    );
  }

  static List<ComentarioLeadModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ComentarioLeadModel.fromRawString(r))
        .toList();
  }
}
