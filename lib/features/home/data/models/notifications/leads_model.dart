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
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return LeadNuevoModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      nombreEmpresa: f(2),
      telefono: f(3),
      asignadoA: f(4),
      fechaHora: f(5),
      idCampania: f(6),
      campania: f(7),
      idEvento: f(8),
      evento: f(9),
      idCanal: f(10),
      canal: f(11),
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
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return LeadReasignadoModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      nombreEmpresa: f(2),
      telefono: f(3),
      asignadoA: f(4),
      fechaHora: f(5),
      idCampania: f(6),
      campania: f(7),
      idEvento: f(8),
      evento: f(9),
      idCanal: f(10),
      canal: f(11),
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