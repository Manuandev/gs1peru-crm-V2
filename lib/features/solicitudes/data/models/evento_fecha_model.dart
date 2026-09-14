// lib/features/solicitudes/data/models/evento_fecha_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/domain/entities/evento_fecha.dart';

class EventoFechaModel extends EventoFechaItem {
  const EventoFechaModel({required super.idFecha, required super.fecha});

  /// Parseo de la task 'EVF' (CRM.CSV_SOLICITUD_LST_APP) — cada registro
  /// trae idFecha¦fecha (fecha en formato dd/MM/yyyy, CONVERT estilo 103).
  factory EventoFechaModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return EventoFechaModel(
      idFecha: ParseUtils.toInt(c, 0),
      fecha: _parseFechaDdMmYyyy(ParseUtils.str(c, 1)),
    );
  }

  static List<EventoFechaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => EventoFechaModel.fromRawString(r))
        .toList();
  }

  static DateTime _parseFechaDdMmYyyy(String raw) {
    final partes = raw.split('/');
    if (partes.length != 3) return DateTime.now();
    return DateTime(
      int.tryParse(partes[2]) ?? DateTime.now().year,
      int.tryParse(partes[1]) ?? 1,
      int.tryParse(partes[0]) ?? 1,
    );
  }
}
