// lib/features/lead/data/models/propuesta_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class PropuestaModel extends Propuesta {
  const PropuestaModel({
    required super.idLead,
    required super.nombre,
    required super.apellido,
    required super.nombreEmpresa,
    required super.telefono,
    required super.isFavorito,
    required super.asignadoA,
    required super.idEstado,
    required super.estado,
    required super.idCampania,
    required super.campania,
    required super.idEvento,
    required super.evento,
    required super.idCanal,
    required super.canal,
    required super.idInteres,
    required super.interes,
    required super.fechaHora,
  });

  factory PropuestaModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return PropuestaModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      apellido: f(2),
      nombreEmpresa: f(3),
      telefono: f(4),
      isFavorito: f(5) == '1' ? true : false,
      asignadoA: f(6),
      idEstado: f(7),
      estado: f(8),
      idCampania: f(9).isEmpty ? null : int.tryParse(f(9)),
      campania: f(10).isEmpty ? null : f(10),
      idEvento: f(11).isEmpty ? null : int.tryParse(f(11)),
      evento: f(12).isEmpty ? null : f(12),
      idCanal: f(13).isEmpty ? null : int.tryParse(f(13)),
      canal: f(14).isEmpty ? null : f(14),
      idInteres: f(15).isEmpty ? null : int.tryParse(f(15)),
      interes: f(16).isEmpty ? null : f(16),
      fechaHora: f(17),
    );
  }

  static List<PropuestaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => PropuestaModel.fromRawString(r))
        .toList();
  }
}
