// lib/features/cobranza/data/models/historial_cobranza_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class HistorialCobranzaModel extends HistorialCobranza {
  const HistorialCobranzaModel({
    required super.idTipo,
    required super.titulo,
    required super.descripcion,
    required super.fecha,
    required super.hora,
    required super.ejecutivo,
  });

  factory HistorialCobranzaModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return HistorialCobranzaModel(
      idTipo: f(0),
      titulo: f(1),
      descripcion: f(2),
      fecha: f(3),
      hora: f(4),
      ejecutivo: f(5),
    );
  }

  static List<HistorialCobranzaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => HistorialCobranzaModel.fromRawString(r))
        .toList();
  }
}
