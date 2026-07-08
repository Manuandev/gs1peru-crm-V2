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
    super.idNumero,
    super.prefijoPais,
    super.numero,
    super.nombres,
    super.apellidoPaterno,
    super.apellidoMaterno,
    super.nombreEmpresa,
    super.correo,
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

  // Índices del SP de detalle de lead (task 'DT'). No trae LD.NOMBRE ni
  // LD.MODALIDAD — nombre/modalidad quedan en su valor por defecto ('').
  // Sí trae contacto/número/correo (1-12) — se usan para no depender de
  // Chat en la pantalla de editar lead.
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
  // 15  EP.ID_ESTADO (padre)  31 CCU.ID_CONVERSACION_CAB
  // 16  EP.DESCRIPCION (padre) 32 CT.ID_CARGO (id crudo, sin catálogo — no se
  //                               parsea acá todavía)
  //                            33 LD.ID_TIP_MONEDA
  factory NegociacionModel.fromDetalleRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return NegociacionModel(
      idLead: ParseUtils.toInt(fields, 0),
      nombre: '',
      modalidad: '',
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
      idNumero: ParseUtils.toInt(fields, 8),
      prefijoPais: ParseUtils.str(fields, 9),
      numero: ParseUtils.str(fields, 10),
      nombres: ParseUtils.str(fields, 2),
      apellidoPaterno: ParseUtils.str(fields, 3),
      apellidoMaterno: ParseUtils.str(fields, 4),
      nombreEmpresa: ParseUtils.str(fields, 5),
      correo: ParseUtils.str(fields, 12),
      idMoneda: ParseUtils.str(fields, 33),
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
