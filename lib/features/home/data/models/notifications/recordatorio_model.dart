// lib/features/home/data/models/notifications/recordatorio_model.dart
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class RecordatorioModel extends Recordatorio {
  const RecordatorioModel({
    required super.idLead,
    required super.nombre,
    required super.nombreEmpresa,
    required super.telefono,
    required super.asignadoA,
    required super.comentario,
    required super.accion,
    required super.aviso,
    required super.fechaHora,
    required super.idCampania,
    required super.campania,
    required super.idEvento,
    required super.evento,
    required super.idCanal,
    required super.canal,
  });

  factory RecordatorioModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return RecordatorioModel(
      idLead:       ParseUtils.toInt(c, 0),
      nombre:       ParseUtils.str(c, 1),
      nombreEmpresa: ParseUtils.str(c, 2),
      telefono:     ParseUtils.str(c, 3),
      asignadoA:    ParseUtils.str(c, 4),
      comentario:   ParseUtils.str(c, 5),
      accion:       ParseUtils.str(c, 6),
      aviso:        ParseUtils.str(c, 7),
      fechaHora:    ParseUtils.str(c, 8),
      idCampania:   ParseUtils.str(c, 9),
      campania:     ParseUtils.str(c, 10),
      idEvento:     ParseUtils.str(c, 11),
      evento:       ParseUtils.str(c, 12),
      idCanal:      ParseUtils.str(c, 13),
      canal:        ParseUtils.str(c, 14),
    );
  }

  static List<RecordatorioModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => RecordatorioModel.fromRawString(r))
        .toList();
  }
}
