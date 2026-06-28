// lib/features/lead/data/models/lead_detalle_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NegociacionLeadModel extends NegociacionLead {
  const NegociacionLeadModel({
    required super.idLead,
    required super.cantidad,
    required super.descuento,
    required super.precioBase,
    required super.precio,
    required super.fechaHora,
    required super.fechaHoraCreacion,
    required super.idEstado,
    required super.descripcionEstado,
    required super.idEstadoPadre,
    required super.descripcionEstadoPadre,
    required super.idCampania,
    required super.nombreCampania,
    required super.idOportunidad,
    required super.nombreOportunidad,
    required super.idCanal,
    required super.descripcionCanal,
    required super.idInteres,
    required super.descripcionInteres,
    required super.activo,
  });

  factory NegociacionLeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return NegociacionLeadModel(
      idLead: ParseUtils.toInt(fields, 0),
      cantidad: ParseUtils.toInt(fields, 1),
      descuento: ParseUtils.toDouble(fields, 2),
      precioBase: ParseUtils.toDouble(fields, 3),
      precio: ParseUtils.toDouble(fields, 4),
      fechaHora: ParseUtils.str(fields, 5),
      fechaHoraCreacion: ParseUtils.str(fields, 6),
      idEstado: ParseUtils.str(fields, 7),
      descripcionEstado: ParseUtils.str(fields, 8),
      idEstadoPadre: ParseUtils.str(fields, 9),
      descripcionEstadoPadre: ParseUtils.str(fields, 10),
      idCampania: ParseUtils.toInt(fields, 11),
      nombreCampania: ParseUtils.str(fields, 12),
      idOportunidad: ParseUtils.toInt(fields, 13),
      nombreOportunidad: ParseUtils.str(fields, 14),
      idCanal: ParseUtils.toInt(fields, 15),
      descripcionCanal: ParseUtils.str(fields, 16),
      idInteres: ParseUtils.toInt(fields, 17),
      descripcionInteres: ParseUtils.str(fields, 18),
      activo: ParseUtils.toBool(fields, 19),
    );
  }

  static List<NegociacionLeadModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NegociacionLeadModel.fromRawString(r))
        .toList();
  }

  static NegociacionLeadModel? parse(String rawResponse) {
    if (rawResponse.trim().isEmpty) return null;
    return NegociacionLeadModel.fromRawString(rawResponse);
  }
}
