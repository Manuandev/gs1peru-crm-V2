// lib/features/home/data/models/asesor_home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class AsesorHomeModel extends AsesorHome {
  const AsesorHomeModel({
    required super.nombre,
    required super.activas,
    required super.nuevos,
    required super.enDesarrollo,
    required super.enLinea,
  });

  // Formato esperado por campo: codAsesor¦nombre¦enLinea(1/0)¦activas¦nuevos
  factory AsesorHomeModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return AsesorHomeModel(
      nombre: ParseUtils.str(fields, 0),
      activas: ParseUtils.toInt(fields, 1),
      nuevos: ParseUtils.toInt(fields, 2),
      enDesarrollo: ParseUtils.toInt(fields, 3),
      enLinea: ParseUtils.toBool(fields, 4),
    );
  }

  static List<AsesorHomeModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => AsesorHomeModel.fromRawString(r))
        .toList();
  }
}
