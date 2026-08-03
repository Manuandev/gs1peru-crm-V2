// lib/features/lead/data/models/negociacion_model.dart
//
// Dos SPs distintos alimentan esta clase — mismo destino (Negociacion),
// shapes de columnas totalmente distintos:
//  - fromRawString       → [CRM].[SP_LeadsLst] task 'LN' (historial de
//    negociaciones de un lead). Columna 21 (LD.IB_ACTIVO) agregada al final
//    sin correr los índices existentes.
//  - fromDetalleRawString → [CRM].[SP_LeadsLst] task 'DT' (detalle de UN
//    lead puntual). Trae además contacto/número/correo intercalados antes
//    de las columnas de estado — no confundir los índices entre ambas.

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NegociacionModel extends Negociacion {
  const NegociacionModel({
    required super.idLead,
    required super.nombre,
    required super.modalidad,
    required super.cantidad,
    required super.precioBase,
    required super.descuento,
    required super.precio,
    required super.fechaHoraInteraccion,
    required super.fechaHoraCreacion,
    required super.idEstado,
    required super.descripcionEstado,
    required super.idEstadoPadre,
    required super.descripcionEstadoPadre,
    required super.idCampania,
    required super.nombreCampania,
    required super.idOportunidad,
    required super.nombreOportunidad,
    required super.idCanal,
    required super.descripcionCanal,
    required super.idInteres,
    required super.descripcionInteres,
    required super.activo,
    super.idMoneda,
    super.totalLeadsNumero,
    super.idContacto,
    super.idNumero,
    super.prefijoPais,
    super.numero,
    super.nombres,
    super.apellidoPaterno,
    super.apellidoMaterno,
    super.nombreEmpresa,
    super.correo,
    super.ruc,
    super.cargo,
    super.numSol,
    super.idEstadoSol,
    super.idChatCab,
    super.fechaPrimerMensajeCliente,
  });

  factory NegociacionModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return NegociacionModel(
      idLead: ParseUtils.toInt(fields, 0),
      nombre: ParseUtils.str(fields, 1),
      modalidad: ParseUtils.str(fields, 2),
      cantidad: ParseUtils.toInt(fields, 3),
      precioBase: ParseUtils.toDouble(fields, 4),
      descuento: ParseUtils.toDouble(fields, 5),
      precio: ParseUtils.toDouble(fields, 6),
      fechaHoraInteraccion: ParseUtils.str(fields, 7),
      fechaHoraCreacion: ParseUtils.str(fields, 8),
      idEstado: ParseUtils.str(fields, 9),
      descripcionEstado: ParseUtils.str(fields, 10),
      idEstadoPadre: ParseUtils.str(fields, 11),
      descripcionEstadoPadre: ParseUtils.str(fields, 12),
      idCampania: ParseUtils.toInt(fields, 13),
      nombreCampania: ParseUtils.str(fields, 14),
      idOportunidad: ParseUtils.toInt(fields, 15),
      nombreOportunidad: ParseUtils.str(fields, 16),
      idCanal: ParseUtils.toInt(fields, 17),
      descripcionCanal: ParseUtils.str(fields, 18),
      idInteres: ParseUtils.toInt(fields, 19),
      descripcionInteres: ParseUtils.str(fields, 20),
      activo: ParseUtils.toBool(fields, 21),
      // 22 → LD.ID_TIP_MONEDA, agregada al final sin correr los índices existentes.
      idMoneda: ParseUtils.str(fields, 22),
      numSol: ParseUtils.str(fields, 23),
      idEstadoSol: ParseUtils.toInt(fields, 24),
      // ⚠️ 'LN' no hace JOIN con CRM.T_CONTACTO — no hay CT.ID_CONTACTO en
      // este shape de columnas, idContacto queda en su default (0). Ver
      // comentario en Negociacion.idContacto.
    );
  }

  static List<NegociacionModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NegociacionModel.fromRawString(r))
        .toList();
  }

  static NegociacionModel? parse(String rawResponse) {
    if (rawResponse.trim().isEmpty) return null;
    return NegociacionModel.fromRawString(rawResponse);
  }

  // Índices del SP de detalle de lead (tasks 'DT' y 'DN' — mismo shape de
  // columnas en ambas desde que se agregó NUMSOL/ESTADO_GES/NOMBRE/MODALIDAD
  // también a 'DN'). Trae contacto/número/correo (1-12) — se usan para no
  // depender de Chat en la pantalla de editar lead.
  //  0  LD.ID_LEAD            17 CP.ID_CAMPANIA
  //  1  CT.ID_CONTACTO        18 CP.NOMBRE
  //  2  CT.NOMBRES            19 OP.ID_OPORTUNIDAD
  //  3  CT.APELLIDO_P         20 OP.NOMBRE
  //  4  CT.APELLIDO_M         21 CN.ID_CANAL
  //  5  EM.NOMBRE             22 CN.NOMBRE
  //  6  CT.ASESOR_PRINCIPAL   23 IT.ID_INTERES
  //  7  FC_USUARIO_M ?? _C (última interacción)
  //  8  NM.ID_NUMERO          24 IT.DESCRIPCION
  //  9  NM.PREFIJO_PAIS       25 conversación abierta (0/1)
  // 10  NM.NUMERO             26 LD.DC_PRECIO_BASE
  // 11  NM.IB_FAVORITO        27 LD.DC_PRECIO
  // 12  CO.CORREO             28 LD.IN_PARTICIPANTES (cantidad)
  // 13  LE.ID_ESTADO          29 LD.DC_DESCUENTO
  // 14  LE.DESCRIPCION        30 LD.FC_USUARIO_C (fecha creación)
  // 15  EP.ID_ESTADO (padre)  31 CCU.ID_CONVERSACION_CAB (→ idChatCab,
  //                               2026-07-15)
  // 16  EP.DESCRIPCION (padre) 32 T_EMPRESA_CONTACTO.NOM_CARGO (texto libre
  //                               — 2026-08-03, antes CT.ID_CARGO; el cargo
  //                               real vive en la empresa vinculada, no en
  //                               el contacto)
  //                            33 LD.ID_TIP_MONEDA
  //                            34 CL.CT_LEADS (total de leads del número)
  //                            35 LI.NUMSOL
  //                            36 CI.ID_ESTADO_GES
  //                            37 LD.NOMBRE
  //                            38 LD.MODALIDAD
  //                            39 EM.RUC (2026-07-15, agregado al final)
  //                            40 PM.FC_PRIMER_MSJ_CLI (2026-07-15) — primer
  //                               mensaje del CLIENTE en la conversación de
  //                               CCU.ID_CONVERSACION_CAB (OUTER APPLY sobre
  //                               CRM.T_CONVERSACION_DET, DIRECCION='CLI'),
  //                               mismo dato que trae 'LS' para
  //                               Numero.fechaPrimerMensajeCliente — acá
  //                               alimenta Negociacion.fechaPrimerMensajeCliente,
  //                               que usa ContactoAccionesFooter para pintar
  //                               el botón de WhatsApp verde/gris.
  factory NegociacionModel.fromDetalleRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return NegociacionModel(
      idLead: ParseUtils.toInt(fields, 0),
      nombre: ParseUtils.str(fields, 37),
      modalidad: ParseUtils.str(fields, 38),
      cantidad: ParseUtils.toInt(fields, 28),
      precioBase: ParseUtils.toDouble(fields, 26),
      descuento: ParseUtils.toDouble(fields, 29),
      precio: ParseUtils.toDouble(fields, 27),
      fechaHoraInteraccion: ParseUtils.str(fields, 7),
      fechaHoraCreacion: ParseUtils.str(fields, 30),
      idEstado: ParseUtils.str(fields, 13),
      descripcionEstado: ParseUtils.str(fields, 14),
      idEstadoPadre: ParseUtils.str(fields, 15),
      descripcionEstadoPadre: ParseUtils.str(fields, 16),
      idCampania: ParseUtils.toInt(fields, 17),
      nombreCampania: ParseUtils.str(fields, 18),
      idOportunidad: ParseUtils.toInt(fields, 19),
      nombreOportunidad: ParseUtils.str(fields, 20),
      idCanal: ParseUtils.toInt(fields, 21),
      descripcionCanal: ParseUtils.str(fields, 22),
      idInteres: ParseUtils.toInt(fields, 23),
      descripcionInteres: ParseUtils.str(fields, 24),
      activo: true,
      // 1 → CT.ID_CONTACTO — ancla real para guardar, ver Negociacion.idContacto.
      idContacto: ParseUtils.toInt(fields, 1),
      idNumero: ParseUtils.toInt(fields, 8),
      prefijoPais: ParseUtils.str(fields, 9),
      numero: ParseUtils.str(fields, 10),
      nombres: ParseUtils.str(fields, 2),
      apellidoPaterno: ParseUtils.str(fields, 3),
      apellidoMaterno: ParseUtils.str(fields, 4),
      nombreEmpresa: ParseUtils.str(fields, 5),
      correo: ParseUtils.str(fields, 12),
      ruc: ParseUtils.str(fields, 39),
      cargo: ParseUtils.str(fields, 32),
      idMoneda: ParseUtils.str(fields, 33),
      totalLeadsNumero: ParseUtils.toInt(fields, 34),
      numSol: ParseUtils.str(fields, 35),
      idEstadoSol: ParseUtils.toInt(fields, 36),
      idChatCab: ParseUtils.toInt(fields, 31),
      fechaPrimerMensajeCliente: ParseUtils.str(fields, 40),
    );
  }

  static List<NegociacionModel> parseDetalleList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NegociacionModel.fromDetalleRawString(r))
        .toList();
  }

  static NegociacionModel? parseDetalle(String rawResponse) {
    if (rawResponse.trim().isEmpty) return null;
    return NegociacionModel.fromDetalleRawString(rawResponse);
  }
}
