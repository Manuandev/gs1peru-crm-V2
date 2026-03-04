// lib\features\reminder\data\models\reminder_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    required super.idRecordatorio,
    required super.fecha,
    required super.hora,
    required super.accion,
    required super.aviso,
    required super.modalidad,
    required super.fechaHora,
    required super.comentario,
    required super.nomApe,
  });

  factory ReminderModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return ReminderModel(
      idRecordatorio: f(0),
      fecha: f(1),
      hora: f(2),
      accion: f(3),
      aviso: f(4),
      modalidad: f(5),
      fechaHora: f(6),
      comentario: f(7),
      nomApe: f(8),
    );
  }

  static List<ReminderModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros) // '¬' separa cada lead
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ReminderModel.fromRawString(r))
        .toList();
  }
}
