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
    // Plantilla.botones/CSV_PLANTILLA_CUD_APP. Task 'LP' (lista, usada por
    // SelectTemplateModal para ENVIAR una plantilla) también manda ahora
    // "idBoton¦texto" por botón, unidos por sepComodin en el campo 9 (no
    // puede reusar sepRegistros ahí: ese separador ya se usa para separar
    // cada PLANTILLA dentro de la lista completa — ver
    // CRM.CSV_PLANTILLA_LST_APP.sql, task 'LP'). El campo 9 de 'DP' es otra
    // cosa (idCampania) — no chocan porque 'DP' siempre trae la sección de
    // sepListas (secciones.length > 1) y 'LP' nunca la trae.
    //
    // Bug real (2026-08-20) — antes 'LP' solo mandaba el texto (sin id), así
    // que cualquier botón cargado por esta vía siempre quedaba con
    // idBoton=0 al reenviarlo por WhatsApp (ENVIAR_WHATSAPP, VAR17) — el
    // backend recibía "0¬SI¬0¬NO" en vez de los ids reales de
    // T_PLANTILLA_WHATSAPP_BOTON. Retrocompatible: si el SP desplegado
    // todavía no manda el id (formato viejo, solo texto sin '¦'), el split
    // por sepCampos da un solo token y cae a idBoton=0/texto=ese token,
    // mismo comportamiento que antes.
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
        : (c.length > 9 && c[9].isNotEmpty
              ? c[9]
                    .split(AppConstants.sepComodin)
                    .map((t) => t.trim())
                    .where((t) => t.isNotEmpty)
                    .map((t) {
                      // Bug real (2026-08-20) — 'LP' usaba sepCampos ('¦')
                      // también DENTRO de cada botón (id¦texto), pero ese
                      // mismo separador ya divide los CAMPOS del registro
                      // completo (c[9] viene de un split por sepCampos sobre
                      // toda la fila) — el '¦' interno cortaba el campo de
                      // botones en pedazos, dejando solo el id del primer
                      // botón como si fuera el texto completo. sepComodin2
                      // ('±') no choca con nada usado en 'LP' (sepCampos =
                      // campos del registro, sepRegistro = separa cada
                      // PLANTILLA, sepComodin = separa botones entre sí).
                      final campos = t.split(AppConstants.sepComodin2);
                      return PlantillaBoton(
                        idBoton: campos.length > 1
                            ? (int.tryParse(campos[0]) ?? 0)
                            : 0,
                        texto: campos.length > 1 ? campos[1] : campos[0],
                      );
                    })
                    .toList()
              : const <PlantillaBoton>[]);

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
