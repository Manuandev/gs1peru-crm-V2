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

    return PrioridadHomeModel(
      idLead: ParseUtils.toInt(fields, 0),
      nombre: ParseUtils.str(fields, 1),
      telefono: ParseUtils.str(fields, 2),
      idEstado: ParseUtils.str(fields, 3),
      estado: ParseUtils.str(fields, 4),
      idCanal: ParseUtils.toInt(fields, 5),
      canal: ParseUtils.str(fields, 6),
      fechaHora: ParseUtils.str(fields, 7),
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
