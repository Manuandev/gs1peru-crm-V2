// lib/features/lead/data/models/lead_model.dart
//
// Parsea la respuesta del SP CSV_LEADS_LST_APP (tasks LS y DT sección 1).
// Índices actualizados según versión del SP con campos económicos (23-26).

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadModel extends Lead {
  const LeadModel({
    required super.idLead,
    required super.idContacto,
    required super.nombre,
    required super.apellido,
    required super.nombreEmpresa,
    required super.asesor,
    required super.fechaHora,
    required super.idNumero,
    required super.prefijo,
    required super.numero,
    required super.isFavorito,
    required super.correo,
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
    super.tieneConversacionAbierta,
    super.nombreContacto,
    super.modalidad,
    super.idEstadoPadre,
    super.descripcionEstadoPadre,
    super.idSubEstado,
    super.subEstado,
    super.precioBase,
    super.precio,
    super.cantidad,
    super.descuento,
  });

  factory LeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    // Nombre de contacto compuesto: nombres (02) + apellidos (03)
    final nombres   = ParseUtils.str(fields, 2);
    final apellidos = ParseUtils.str(fields, 3);
    final nombreContacto =
        '$nombres $apellidos'.trim().isEmpty ? null : '$nombres $apellidos'.trim();

    return LeadModel(
      // 00 → idLead
      idLead:    ParseUtils.toInt(fields, 0),
      // 01 → idContacto
      idContacto: ParseUtils.toInt(fields, 1),
      // 02 → nombres   (campo principal de nombre en la lista)
      nombre:    nombres,
      // 03 → apellidos (campo principal de apellido en la lista)
      apellido:  apellidos,
      nombreContacto: nombreContacto,
      // 04 → empresa
      nombreEmpresa: ParseUtils.str(fields, 4),
      // 05 → asesorPrincipal
      asesor:    ParseUtils.str(fields, 5),
      // 06 → fechaModificacion
      fechaHora: ParseUtils.str(fields, 6),
      // 07 → idNumero
      idNumero:  ParseUtils.toInt(fields, 7),
      // 08 → prefijoPais
      prefijo:   ParseUtils.str(fields, 8),
      // 09 → numero
      numero:    ParseUtils.str(fields, 9),
      // 10 → esFavorito
      isFavorito: ParseUtils.toBool(fields, 10),
      // 11 → correo
      correo:    ParseUtils.str(fields, 11),
      // 12 → idEstado
      idEstado:  ParseUtils.str(fields, 12),
      // 13 → descripcionEstado
      estado:    ParseUtils.str(fields, 13),
      // 14 → idCampania
      idCampania: ParseUtils.toInt(fields, 14),
      // 15 → nombreCampania
      campania:  ParseUtils.str(fields, 15),
      // 16 → idOportunidad
      idEvento:  ParseUtils.toInt(fields, 16),
      // 17 → nombreOportunidad
      evento:    ParseUtils.str(fields, 17),
      // 18 → idCanal
      idCanal:   ParseUtils.toInt(fields, 18),
      // 19 → descripcionCanal
      canal:     ParseUtils.str(fields, 19),
      // 20 → idInteres
      idInteres: ParseUtils.toInt(fields, 20),
      // 21 → descripcionInteres
      interes:   ParseUtils.str(fields, 21),
      // 22 → tieneConversacionAbierta
      tieneConversacionAbierta: ParseUtils.toBool(fields, 22),
      // 23 → precioBase
      precioBase: ParseUtils.toDouble(fields, 23),
      // 24 → precio
      precio:    ParseUtils.toDouble(fields, 24),
      // 25 → cantidad  (SP devuelve 0 hardcodeado — campo en desarrollo)
      cantidad:  ParseUtils.toDouble(fields, 25),
      // 26 → descuento (SP devuelve 0 hardcodeado — campo en desarrollo)
      descuento: ParseUtils.toDouble(fields, 26),
    );
  }

  static List<LeadModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => LeadModel.fromRawString(r))
        .toList();
  }

  static LeadModel? parse(String rawResponse) {
    if (rawResponse.trim().isEmpty) return null;
    return LeadModel.fromRawString(rawResponse);
  }
}
