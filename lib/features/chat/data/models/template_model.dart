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
    // Task 'LP' (lista) manda un solo bloque de campos por registro — nunca
    // trae sepListas, así que este split no le afecta. Task 'DP' (detalle,
    // ver getPlantilla) agrega una segunda sección con los botones, separada
    // por sepListas: campos¯botón¬botón¬botón.
    final secciones = raw.split(AppConstants.sepListas);
    final c = ParseUtils.campos(secciones[0], AppConstants.sepCampos);
    // Cada botón viaja "idBoton¦texto" (id=0 = nuevo) — ver comentario en
    // Plantilla.botones/CSV_PLANTILLA_CUD_APP.
    final botones = secciones.length > 1
        ? secciones[1]
              .split(AppConstants.sepRegistros)
              .map((b) => b.trim())
              .where((b) => b.isNotEmpty)
              .map((b) {
                final campos = b.split(AppConstants.sepCampos);
                return PlantillaBoton(
                  idBoton: int.tryParse(campos[0]) ?? 0,
                  texto: campos.length > 1 ? campos[1] : '',
                );
              })
              .toList()
        : const <PlantillaBoton>[];

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
      idCampania: ParseUtils.toInt(c, 9),
      idOportunidad: ParseUtils.toInt(c, 10),
      idEstadoNegociacion: ParseUtils.str(c, 11),
      activo: c.length > 12 ? ParseUtils.toBool(c, 12) : true,
      compartir: ParseUtils.toBool(c, 13),
      botones: botones,
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
