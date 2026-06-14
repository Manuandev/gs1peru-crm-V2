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
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return TemplateModel(
      idPlantilla: int.parse(f(0)),
      nombre: f(1),
      idCampania: int.parse(f(2)),
      idEvento: int.parse(f(3)),
      detalle: f(4),
      rutaArchivo: f(5),
      nombreArchivo: f(6),
      extensionArchivo: f(7),
      isBoton: f(8) == '1',
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
