// lib/features/lead/data/models/lead_recordatorio_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRecordatorioModel extends LeadRecordatorio {
  const LeadRecordatorioModel({
    required super.idRecordatorio,
    required super.idLead,
    required super.idContacto,
    required super.fechaRecordatorio,
    required super.comentario,
    required super.campania,
    required super.oportunidad,
    required super.avisoDescripcion,
    required super.avisoMinutos,
    required super.accionDescripcion,
    required super.idUsuarioC,
  });

  /// Parseo del SP 'LRN' (CRM.CSV_LEADS_LST_APP) — 11 campos posicionales:
  /// 0 idRecordatorio, 1 idLead, 2 idContacto, 3 fechaRecordatorio,
  /// 4 comentario, 5 campania, 6 oportunidad, 7 avisoDescripcion,
  /// 8 avisoMinutos, 9 accionDescripcion, 10 idUsuarioC (CODUSER crudo).
  factory LeadRecordatorioModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return LeadRecordatorioModel(
      idRecordatorio: ParseUtils.toInt(fields, 0),
      idLead: ParseUtils.toInt(fields, 1),
      idContacto: ParseUtils.toInt(fields, 2),
      fechaRecordatorio: ParseUtils.str(fields, 3),
      comentario: ParseUtils.str(fields, 4),
      campania: ParseUtils.str(fields, 5),
      oportunidad: ParseUtils.str(fields, 6),
      avisoDescripcion: ParseUtils.str(fields, 7),
      avisoMinutos: ParseUtils.toInt(fields, 8),
      accionDescripcion: ParseUtils.str(fields, 9),
      idUsuarioC: ParseUtils.str(fields, 10),
    );
  }

  static List<LeadRecordatorioModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadRecordatorioModel.fromRawString(r))
        .toList();
  }
}
