// lib/features/lead/data/models/lead_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadModel extends Lead {
  const LeadModel({
    required super.idLead,
    required super.nombre,
    required super.apellido,
    required super.nombreEmpresa,
    required super.telefono,
    required super.isFavorito,
    required super.asignadoA,
    required super.fechaHora,
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
    required super.ibChat,
  });

  factory LeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return LeadModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      apellido: f(2),
      nombreEmpresa: f(3),
      telefono: f(4),
      isFavorito: f(5) == '1' ? true : false,
      asignadoA: f(6),
      fechaHora: f(7),
      idEstado: f(8),
      estado: f(9),
      idCampania: int.tryParse(f(10)) ?? 0,
      campania: f(11).isEmpty ? null : f(11),
      idEvento: int.tryParse(f(12)) ?? 0,
      evento: f(13).isEmpty ? null : f(13),
      idCanal: int.tryParse(f(14)) ?? 0,
      canal: f(15).isEmpty ? null : f(15),
      idInteres: f(16).isEmpty ? null : int.tryParse(f(16)),
      interes: f(17).isEmpty ? null : f(17),
      ibChat: f(18) == '1' ? true : false,
    );
  }

  static List<LeadModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadModel.fromRawString(r))
        .toList();
  }
}
