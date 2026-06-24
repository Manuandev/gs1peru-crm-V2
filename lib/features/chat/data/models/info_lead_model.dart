// lib/features/chat/data/models/info_lead_model.dart
//
// Parsea la respuesta del SP CSV_WHATSAPP_LST_APP (task D y task LS).
// Retorna un Lead unificado. Los flags de conversación (isBloqueado/isExpirado/
// isCerrado) se exponen como campos extra porque pertenecen al número,
// no a la entidad Lead — InfoLeadCubit los almacena en su estado aparte.

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class InfoLeadModel extends Lead {
  // Flags de estado de conversación WhatsApp — no van en Lead
  final bool isBloqueado;
  final bool isExpirado;
  final bool isCerrado;

  const InfoLeadModel({
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
    required this.isBloqueado,
    required this.isExpirado,
    required this.isCerrado,
  });

  factory InfoLeadModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    // Nombre de contacto compuesto desde campos del SP de chats
    final nombres   = ParseUtils.str(fields, 1);
    final apellidoP = ParseUtils.str(fields, 2);
    final apellidoM = ParseUtils.str(fields, 3);
    final apellido  = '$apellidoP $apellidoM'.trim();
    final nombreContacto = '$nombres $apellidoP $apellidoM'.trim();

    return InfoLeadModel(
      // 00 → idContacto
      idContacto:  ParseUtils.toInt(fields, 0),
      // 01 → nombres
      nombre:      nombres,
      // 02 + 03 → apellidoP + apellidoM
      apellido:    apellido,
      nombreContacto: nombreContacto.isEmpty ? null : nombreContacto,
      // 04 → asesorPrincipal
      asesor:      ParseUtils.str(fields, 4),
      // 05 → idEmpresa (ignorado — sin campo en Lead)
      // 06 → ruc (ignorado)
      // 07 → nombreEmpresa
      nombreEmpresa: ParseUtils.str(fields, 7),
      // 08 → direccionEmpresa (ignorado)
      // 09 → idNumero
      idNumero:    ParseUtils.toInt(fields, 9),
      // 10 → prefijoPais
      prefijo:     ParseUtils.str(fields, 10),
      // 11 → numero
      numero:      ParseUtils.str(fields, 11),
      // 12 → ibPrincipal (ignorado)
      // 13 → esFavorito
      isFavorito:  ParseUtils.toBool(fields, 13),
      // 14 → ibBloqueado (pertenece al número, no a Lead)
      isBloqueado: ParseUtils.toBool(fields, 14),
      // 15 → ibExpirado (pertenece al número, no a Lead)
      isExpirado:  ParseUtils.toBool(fields, 15),
      // 16 → ibCerrado (pertenece al número, no a Lead)
      isCerrado:   ParseUtils.toBool(fields, 16),
      // 17 → idLead
      idLead:      ParseUtils.toInt(fields, 17),
      // 18 → modalidad
      modalidad:   ParseUtils.str(fields, 18),
      // 19 → precioBase
      precioBase:  ParseUtils.toDouble(fields, 19),
      // 20 → precio
      precio:      ParseUtils.toDouble(fields, 20),
      // 21 → cantidad (SP devuelve 0 hardcodeado)
      cantidad:    ParseUtils.toDouble(fields, 21),
      // 22 → descuento (SP devuelve 0 hardcodeado)
      descuento:   ParseUtils.toDouble(fields, 22),
      // 23 → idEstado
      idEstado:    ParseUtils.str(fields, 23),
      // 24 → descripcionEstado
      estado:      ParseUtils.str(fields, 24),
      // 25 → idEstadoPadre
      idEstadoPadre: ParseUtils.str(fields, 25),
      // 26 → descripcionEstadoPadre
      descripcionEstadoPadre: ParseUtils.str(fields, 26),
      // 27 → idCampania
      idCampania:  ParseUtils.toInt(fields, 27),
      // 28 → nombreCampania
      campania:    ParseUtils.str(fields, 28),
      // 29 → idOportunidad
      idEvento:    ParseUtils.toInt(fields, 29),
      // 30 → nombreOportunidad
      evento:      ParseUtils.str(fields, 30),
      // 31 → idCanal
      idCanal:     ParseUtils.toInt(fields, 31),
      // 32 → descripcionCanal
      canal:       ParseUtils.str(fields, 32),
      // 33 → idInteres
      idInteres:   ParseUtils.toInt(fields, 33),
      // 34 → descripcionInteres
      interes:     ParseUtils.str(fields, 34),
      // Campos no disponibles en el SP de chats
      correo:      '',
      fechaHora:   '',
      // Índices 35-42 (mensaje, archivo) los usa ChatModel — no se parsean aquí
    );
  }

  static InfoLeadModel parse(String rawResponse) {
    final raw = rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .first;
    return InfoLeadModel.fromRawString(raw);
  }
}
