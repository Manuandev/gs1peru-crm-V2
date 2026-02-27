// lib\features\home\data\models\recordatorio_model.dart

import 'package:app_crm/core/constants/app_constants.dart';

class RecordatorioItem {
  final String idRecordatorio; // 00 - ID_RECORDATORIO
  final String fecha; // 01 - FCH_CREACION
  final String hora; // 02 - HORA
  final String accion; // 03 - Enviar WhatsApp, Enviar correo
  final String aviso; // 04 - 5 minutos antes
  final String modalidad; // 05 - test
  final String fechaHora; // 06 - FECHA Y HORA: 25/10/2024 - 19:48
  final String comentario; // 07 - nota recordatorio
  final String nomApe; // 08 - Nombres y apellidos

  const RecordatorioItem({
    required this.idRecordatorio,
    required this.fecha,
    required this.hora,
    required this.accion,
    required this.aviso,
    required this.modalidad,
    required this.fechaHora,
    required this.comentario,
    required this.nomApe,
  });

  factory RecordatorioItem.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return RecordatorioItem(
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

  static List<RecordatorioItem> parseLeadList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros) // '¬' separa cada lead
        .where((r) => r.trim().isNotEmpty)
        .map((r) => RecordatorioItem.fromRawString(r))
        .toList();
  }
}
