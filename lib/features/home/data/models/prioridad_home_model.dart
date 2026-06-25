// lib/features/home/data/models/prioridad_home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class PrioridadHomeModel extends PrioridadHome {
  const PrioridadHomeModel({
    required super.idNumero,
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

    return PrioridadHomeModel(
      idNumero: ParseUtils.toInt(fields, 0),
      idLead: ParseUtils.toInt(fields, 1),
      nombre: ParseUtils.str(fields, 2),
      telefono: ParseUtils.str(fields, 3),
      idEstado: ParseUtils.str(fields, 4),
      estado: ParseUtils.str(fields, 5),
      idCanal: ParseUtils.toInt(fields, 6),
      canal: ParseUtils.str(fields, 7),
      fechaHora: ParseUtils.str(fields, 8),
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
