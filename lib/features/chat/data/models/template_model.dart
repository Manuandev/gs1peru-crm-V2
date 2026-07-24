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
    super.idCampania,
    super.idOportunidad,
    super.idEstadoNegociacion,
    super.activo,
    super.compartir,
    super.botones,
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
      // Índices 9-13: campos de gestión — el SP todavía no los devuelve
      // (parte [4] del SP `LP` actual solo trae 0-8). ParseUtils.str/toInt/
      // toBool ya devuelven el default si el índice no existe, así que esto
      // no rompe con el raw actual y queda listo para cuando el SP los sume.
      idCampania: ParseUtils.toInt(c, 9),
      idOportunidad: ParseUtils.toInt(c, 10),
      idEstadoNegociacion: ParseUtils.str(c, 11),
      activo: c.length > 12 ? ParseUtils.toBool(c, 12) : true,
      compartir: ParseUtils.toBool(c, 13),
      // botones: lista de textos — el SP aún no define cómo viajan dentro de
      // un mismo registro (sub-separador pendiente), se deja vacía por ahora.
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
