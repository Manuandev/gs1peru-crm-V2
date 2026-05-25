// lib\features\lead\data\models\home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class PrioridadModel extends Prioridad {
  const PrioridadModel({
    required super.idLead,
    required super.nombre,
    required super.telefono,
    required super.idEstado,
    required super.estado,
    required super.idCanal,
    required super.canal,
    required super.fechaHora,
  });

  factory PrioridadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return PrioridadModel(
        idLead: int.parse(f(0)),
        nombre: f(1),
        telefono: f(2),
        idEstado: f(3),
        estado: f(4),
        idCanal: f(5),
        canal: f(6),
        fechaHora: f(7),
    );
  }

  static List<PrioridadModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros) 
        .where((r) => r.trim().isNotEmpty)
        .map((r) => PrioridadModel.fromRawString(r))
        .toList();
  }
}
