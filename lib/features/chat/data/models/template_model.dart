// lib/features/chat/data/models/template_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class PlantillaModel extends Plantilla {
  const PlantillaModel({
    required super.idPlantilla,
    required super.nombre,
    required super.contenido,
    required super.nombreCampania,
    required super.nombreOportunidad,
    required super.ibActivo,
    required super.idMeta,
    required super.estadoMeta,
  });

  factory PlantillaModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return PlantillaModel(
      idPlantilla:       ParseUtils.toInt(c, 0),
      nombre:            ParseUtils.str(c, 1),
      contenido:         ParseUtils.str(c, 2),
      nombreCampania:    ParseUtils.str(c, 3),
      nombreOportunidad: ParseUtils.str(c, 4),
      ibActivo:          ParseUtils.toBool(c, 5),
      idMeta:            ParseUtils.str(c, 6),
      estadoMeta:        ParseUtils.str(c, 7),
    );
  }

  static List<PlantillaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => PlantillaModel.fromRawString(r))
        .toList();
  }
}
