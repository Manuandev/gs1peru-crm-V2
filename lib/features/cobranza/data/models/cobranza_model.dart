// lib/features/cobranza/data/models/cobranza_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaModel extends Cobranza {
  const CobranzaModel({
    required super.idCobranza,
    required super.nombre,
    required super.apellido,
    required super.evento,
    required super.montoTotal,
    required super.ejecutivo,
    required super.asignadoA,
    required super.idCondicion,
    required super.condicion,
    required super.fecha,
    super.fechaVencimiento,
    super.diasVencimiento,
    required super.idEstado,
    required super.estado,
    required super.telefono,
  });

  factory CobranzaModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return CobranzaModel(
      idCobranza: int.tryParse(f(0)) ?? 0,
      nombre: f(1),
      apellido: f(2),
      evento: f(3),
      montoTotal: double.tryParse(f(4)) ?? 0.0,
      ejecutivo: f(5),
      asignadoA: f(6),
      idCondicion: f(7),
      condicion: f(8),
      fecha: f(9),
      fechaVencimiento: f(10).isEmpty ? null : f(10),
      diasVencimiento: f(11).isEmpty ? null : int.tryParse(f(11)),
      idEstado: f(12),
      estado: f(13),
      telefono: f(14),
    );
  }

  static List<CobranzaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => CobranzaModel.fromRawString(r))
        .toList();
  }
}
