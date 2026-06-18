// lib/features/lead/data/models/lead_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadModel extends Lead {
  const LeadModel({
    required super.idLead,
    required super.idContacto,
    required super.nombre,
    required super.apellido,
    required super.nombreEmpresa,
    required super.asesor,
    required super.fechaHora,
    required super.idNumero,
    required super.prefijo,
    required super.numero,
    required super.isFavorito,
    required super.correo,
    required super.idEstado,
    required super.estado,
    required super.idCampania,
    required super.campania,
    required super.idEvento,
    required super.evento,
    required super.idCanal,
    required super.canal,
    required super.idInteres,
    required super.interes,
    required super.ibChat,
    required super.monto,
  });

  factory LeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return LeadModel(
      idLead: ParseUtils.toInt(fields, 0),
      idContacto: ParseUtils.toInt(fields, 1),
      nombre: ParseUtils.str(fields, 2),
      apellido: ParseUtils.str(fields, 3),
      nombreEmpresa: ParseUtils.str(fields, 4),
      asesor: ParseUtils.str(fields, 5),
      fechaHora: ParseUtils.str(fields, 6),
      idNumero: ParseUtils.toInt(fields, 7),
      prefijo: ParseUtils.str(fields, 8),
      numero: ParseUtils.str(fields, 9),
      isFavorito: ParseUtils.str(fields, 10) == '1' ? true : false,
      correo: ParseUtils.str(fields, 11),
      idEstado: ParseUtils.str(fields, 12),
      estado: ParseUtils.str(fields, 13),
      idCampania: ParseUtils.toInt(fields, 14),
      campania: ParseUtils.str(fields, 15),
      idEvento: ParseUtils.toInt(fields, 16),
      evento: ParseUtils.str(fields, 17),
      idCanal: ParseUtils.toInt(fields, 18),
      canal: ParseUtils.str(fields, 19),
      idInteres: ParseUtils.toInt(fields, 20),
      interes: ParseUtils.str(fields, 21),
      ibChat: ParseUtils.str(fields, 22) == '1' ? true : false,
      // TODO: ajustar índice (23) cuando el SP incluya monto en su respuesta
      monto: ParseUtils.toDouble(fields, 23),
    );
  }

  static List<LeadModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadModel.fromRawString(r))
        .toList();
  }

  static LeadModel? parse(String rawResponse) {
    if (rawResponse.trim().isEmpty) return null;
    return LeadModel.fromRawString(rawResponse);
  }
}
