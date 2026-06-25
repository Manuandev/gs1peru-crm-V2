// lib/features/chat/data/models/template_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class TemplateModel extends Template {
  const TemplateModel({
    required super.idPlantilla,
    required super.nombre,
    required super.idCampania,
    required super.idEvento,
    required super.detalle,
    required super.rutaArchivo,
    required super.nombreArchivo,
    required super.extensionArchivo,
    required super.isBoton,
  });

  factory TemplateModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return TemplateModel(
      idPlantilla:      ParseUtils.toInt(c, 0),
      nombre:           ParseUtils.str(c, 1),
      idCampania:       ParseUtils.toInt(c, 2),
      idEvento:         ParseUtils.toInt(c, 3),
      detalle:          ParseUtils.str(c, 4),
      rutaArchivo:      ParseUtils.str(c, 5),
      nombreArchivo:    ParseUtils.str(c, 6),
      extensionArchivo: ParseUtils.str(c, 7),
      isBoton:          ParseUtils.toBool(c, 8),
    );
  }

  static List<TemplateModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => TemplateModel.fromRawString(r))
        .toList();
  }
}
