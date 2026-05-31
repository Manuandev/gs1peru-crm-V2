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
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return RecordatorioModel(
      idLead: int.parse(f(0)),
      nombre: f(1),
      nombreEmpresa: f(2),
      telefono: f(3),
      asignadoA: f(4),
      comentario: f(5),
      accion: f(6),
      aviso: f(7),
      fechaHora: f(8),
      idCampania: f(9),
      campania: f(10),
      idEvento: f(11),
      evento: f(12),
      idCanal: f(13),
      canal: f(14),
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
