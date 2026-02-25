// lib\features\home\data\models\lead_model.dart
// ============================================================
// USER MODEL — Global para toda la app.
// Vive solo en MEMORIA mientras la app está activa.
// Nunca se persiste en SQLite.
// Lo usan todos los features que necesiten datos del usuario.
// ============================================================

import 'package:app_crm/core/constants/app_constants.dart';

class LeadItem {
  final String userCreacion; // 00 - ID_CREACION
  final String idLead; // 01 - ID_LEAD
  final String fecha; // 02 - FCH_CREACION
  final String dia; // 03 - Lunes, Martes...
  final String numDia; // 04 - día numérico
  final String mes; // 05 - Enero, Febrero...
  final String anho; // 06 - YEAR
  final String hora; // 07 - HH:mm
  final String dni; // 08 - DNI

  const LeadItem({
    required this.userCreacion,
    required this.idLead,
    required this.fecha,
    required this.dia,
    required this.numDia,
    required this.mes,
    required this.anho,
    required this.hora,
    required this.dni,
  });

  factory LeadItem.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return LeadItem(
      userCreacion: f(0),
      idLead: f(1),
      fecha: f(2),
      dia: f(3),
      numDia: f(4),
      mes: f(5),
      anho: f(6),
      hora: f(7),
      dni: f(8),
    );
  }

  static List<LeadItem> parseLeadList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros) // '¬' separa cada lead
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadItem.fromRawString(r))
        .toList();
  }
}

class LeadDetalle {
  final String idCreacion; // 00 - ID_CREACION
  final String documento; // 01 - RUC o NRO_DOC
  final String nombre; // 02 - Nombre empresa o persona
  final String telefono; // 03 - TELEFONO_1
  final String correo; // 04 - CORREO_1
  final String oportunidad; // 05 - NOMBRE oportunidad

  const LeadDetalle({
    required this.idCreacion,
    required this.documento,
    required this.nombre,
    required this.telefono,
    required this.correo,
    required this.oportunidad,
  });

  factory LeadDetalle.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    return LeadDetalle(
      idCreacion: f(0),
      documento: f(1),
      nombre: f(2),
      telefono: f(3),
      correo: f(4),
      oportunidad: f(5),
    );
  }
}
