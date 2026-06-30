// lib/features/chat/data/models/template_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class PlantillaModel extends Plantilla {
  const PlantillaModel({
    required super.idPlantilla,
    required super.nombre,
    required super.idMeta,
    required super.estadoMeta,
    required super.contenido,
    required super.archivoRuta,
    required super.archivoNombre,
    required super.archivoExt,
    required super.tieneBoton,
  });

  factory PlantillaModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);

    return PlantillaModel(
      idPlantilla: ParseUtils.toInt(c, 0),
      nombre: ParseUtils.str(c, 1),
      idMeta: ParseUtils.str(c, 2),
      estadoMeta: ParseUtils.str(c, 3),
      contenido: ParseUtils.str(c, 4),
      archivoRuta: ParseUtils.str(c, 5),
      archivoNombre: ParseUtils.str(c, 6),
      archivoExt: ParseUtils.str(c, 7),
      tieneBoton: ParseUtils.toBool(c, 8),
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
