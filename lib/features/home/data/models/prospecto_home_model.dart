// lib/features/home/data/models/prospecto_home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class ProspectoHomeModel extends ProspectoHome {
  const ProspectoHomeModel({
    required super.idLead,
    required super.nombre,
    required super.nombreEmpresa,
    required super.fechaHora,
  });

  factory ProspectoHomeModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return ProspectoHomeModel(
      idLead: ParseUtils.toInt(fields, 0),
      nombre: ParseUtils.str(fields, 1),
      nombreEmpresa: ParseUtils.str(fields, 2),
      fechaHora: ParseUtils.str(fields, 3),
    );
  }

  static List<ProspectoHomeModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ProspectoHomeModel.fromRawString(r))
        .toList();
  }
}
