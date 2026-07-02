// lib/features/lead/data/models/lead_model.dart
//
// Parsea la respuesta del SP CSV_LEADS_LST_APP (tasks LS y DT).
// El SP retorna EP.ID_ESTADO y EP.DESCRIPCION (estado padre) en [15] y [16],
// desplazando campaña, oportunidad, canal e interés a [17..24].

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadModel extends Lead {
  const LeadModel({
    required super.idLead,
    required super.idContacto,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.nombreEmpresa,
    required super.asesor,
    required super.fechaHora,
    super.fechaCreacion,
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
    super.nombreLead,
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

    final nombres      = ParseUtils.str(fields, 2);
    final apellidoP    = ParseUtils.str(fields, 3);
    final apellidoM    = ParseUtils.str(fields, 4);
    final nombreContacto = '$nombres $apellidoP $apellidoM'.trim().isEmpty
        ? null
        : '$nombres $apellidoP $apellidoM'.trim();

    return LeadModel(
      // 00 → idLead
      idLead:       ParseUtils.toInt(fields, 0),
      // 01 → idContacto
      idContacto:   ParseUtils.toInt(fields, 1),
      // 02 → nombres
      nombre:       nombres,
      // 03 → apellidoPaterno
      apellidoPaterno: apellidoP,
      // 04 → apellidoMaterno
      apellidoMaterno: apellidoM,
      nombreContacto:  nombreContacto,
      // 05 → empresa
      nombreEmpresa: ParseUtils.str(fields, 5),
      // 06 → asesorPrincipal
      asesor:        ParseUtils.str(fields, 6),
      // 07 → fechaModificacion
      fechaHora:     ParseUtils.str(fields, 7),
      // 08 → idNumero
      idNumero:      ParseUtils.toInt(fields, 8),
      // 09 → prefijoPais
      prefijo:       ParseUtils.str(fields, 9),
      // 10 → numero
      numero:        ParseUtils.str(fields, 10),
      // 11 → esFavorito
      isFavorito:    ParseUtils.toBool(fields, 11),
      // 12 → correo
      correo:        ParseUtils.str(fields, 12),
      // 13 → idEstado
      idEstado:      ParseUtils.str(fields, 13),
      // 14 → descripcionEstado
      estado:        ParseUtils.str(fields, 14),
      // 15 → EP.ID_ESTADO (estado padre)
      idEstadoPadre: ParseUtils.strNullable(fields, 15),
      // 16 → EP.DESCRIPCION (descripcion estado padre)
      descripcionEstadoPadre: ParseUtils.strNullable(fields, 16),
      // 17 → idCampania
      idCampania:    ParseUtils.toInt(fields, 17),
      // 18 → nombreCampania
      campania:      ParseUtils.str(fields, 18),
      // 19 → idOportunidad
      idEvento:      ParseUtils.toInt(fields, 19),
      // 20 → nombreOportunidad
      evento:        ParseUtils.str(fields, 20),
      // 21 → idCanal
      idCanal:       ParseUtils.toInt(fields, 21),
      // 22 → descripcionCanal
      canal:         ParseUtils.str(fields, 22),
      // 23 → idInteres
      idInteres:     ParseUtils.toInt(fields, 23),
      // 24 → descripcionInteres
      interes:       ParseUtils.str(fields, 24),
      // 25 → tieneConversacionAbierta
      tieneConversacionAbierta: ParseUtils.toBool(fields, 25),
      // 26 → precioBase
      precioBase:    ParseUtils.toDouble(fields, 26),
      // 27 → precio (costoFinal)
      precio:        ParseUtils.toDouble(fields, 27),
      // 28 → cantidad
      cantidad:      ParseUtils.toInt(fields, 28),
      // 29 → descuento
      descuento:     ParseUtils.toDouble(fields, 29),
      // 30 → fecha de creación real (LD.FC_USUARIO_C) — solo presente en task 'DT'
      fechaCreacion: ParseUtils.strNullable(fields, 30),
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
