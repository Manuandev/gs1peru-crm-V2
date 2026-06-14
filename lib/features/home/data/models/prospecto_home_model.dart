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
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ProspectoHomeModel(
        idLead: int.parse(f(0)),
        nombre: f(1),
        nombreEmpresa: f(2),
        fechaHora: f(3),
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
