// lib/features/home/data/models/notifications/leads_model.dart
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class LeadNuevoModel extends LeadNuevo {
  const LeadNuevoModel({
    required super.idLead,
    required super.nombre,
    required super.nombreEmpresa,
    required super.telefono,
    required super.asignadoA,
    required super.fechaHora,
    required super.idCampania,
    required super.campania,
    required super.idEvento,
    required super.evento,
    required super.idCanal,
    required super.canal,
  });

  factory LeadNuevoModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return LeadNuevoModel(
      idLead:       ParseUtils.toInt(c, 0),
      nombre:       ParseUtils.str(c, 1),
      nombreEmpresa: ParseUtils.str(c, 2),
      telefono:     ParseUtils.str(c, 3),
      asignadoA:    ParseUtils.str(c, 4),
      fechaHora:    ParseUtils.str(c, 5),
      idCampania:   ParseUtils.str(c, 6),
      campania:     ParseUtils.str(c, 7),
      idEvento:     ParseUtils.str(c, 8),
      evento:       ParseUtils.str(c, 9),
      idCanal:      ParseUtils.str(c, 10),
      canal:        ParseUtils.str(c, 11),
    );
  }

  static List<LeadNuevoModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadNuevoModel.fromRawString(r))
        .toList();
  }
}



class LeadReasignadoModel extends LeadReasignado {
  const LeadReasignadoModel({
    required super.idLead,
    required super.nombre,
    required super.nombreEmpresa,
    required super.telefono,
    required super.asignadoA,
    required super.fechaHora,
    required super.idCampania,
    required super.campania,
    required super.idEvento,
    required super.evento,
    required super.idCanal,
    required super.canal,
  });

  factory LeadReasignadoModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return LeadReasignadoModel(
      idLead:       ParseUtils.toInt(c, 0),
      nombre:       ParseUtils.str(c, 1),
      nombreEmpresa: ParseUtils.str(c, 2),
      telefono:     ParseUtils.str(c, 3),
      asignadoA:    ParseUtils.str(c, 4),
      fechaHora:    ParseUtils.str(c, 5),
      idCampania:   ParseUtils.str(c, 6),
      campania:     ParseUtils.str(c, 7),
      idEvento:     ParseUtils.str(c, 8),
      evento:       ParseUtils.str(c, 9),
      idCanal:      ParseUtils.str(c, 10),
      canal:        ParseUtils.str(c, 11),
    );
  }

  static List<LeadReasignadoModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadReasignadoModel.fromRawString(r))
        .toList();
  }
}