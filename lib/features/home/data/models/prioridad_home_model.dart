// lib/features/home/data/models/prioridad_home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class PrioridadHomeModel extends PrioridadHome {
  const PrioridadHomeModel({
    required super.idLead,
    required super.nombre,
    required super.telefono,
    required super.idEstado,
    required super.estado,
    required super.idCanal,
    required super.canal,
    required super.fechaHora,
  });

  factory PrioridadHomeModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return PrioridadHomeModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      telefono: f(2),
      idEstado: f(3),
      estado: f(4),
      idCanal: int.tryParse(f(5)) ?? 0,
      canal: f(6),
      fechaHora: f(7),
    );
  }

  static List<PrioridadHomeModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => PrioridadHomeModel.fromRawString(r))
        .toList();
  }
}
