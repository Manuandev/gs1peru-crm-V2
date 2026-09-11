// lib/features/solicitudes/data/models/solicitud_detalle_real_model.dart
//
// Parseo de [CRM].[CSV_SOLICITUD_LST_APP], task 'DV' — detalle de SOLO
// LECTURA de una solicitud ya guardada, dado su NUMSOL. Pensado para
// SolicitudDetalleView, no para el formulario (ese sigue usando 'DT').
// El SP resuelve la mayoría de descripciones (comprobante, razón social,
// etc.) directo en texto — salvo el tipo de documento, que llega como id
// crudo (ID_TIPO_DOCUMENTO) y se resuelve en la vista contra
// CatalogsBloc.tiposDocumento, mismo catálogo que ya usa el wizard.
//
// 3 secciones separadas por sepListas:
//   [0] datos principales (sepCampos, ver mapeo abajo)
//   [1] historial (sepRegistros ¦ idLead¦LS.DESCRIPCION¦LA.ORIGEN¦LA.NOMBRE¦
//       LA.DESCRIPCION¦fecha — mismo formato que la sección [2] de la 'DT'
//       de Cobranza, HistorialCobranzaModel)
//   [2] cabecera (2026-09-11) — la MISMA fila que el 'LSP' (campos 0..23),
//       parseada con SolicitudModel.fromRawString. Reemplaza la segunda
//       llamada al 'LS' (lista completa) que hacía el detalle. Si el SP
//       desplegado todavía no la trae, `cabecera` queda null.

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudDetalleRealModel extends SolicitudDetalle {
  const SolicitudDetalleRealModel({
    required super.numSol,
    required super.tipoDocumentoId,
    required super.numDoc,
    required super.cargo,
    required super.celular,
    required super.correo,
    required super.facTipoComprobante,
    required super.facRazonSocial,
    required super.facRuc,
    required super.facDireccion,
    super.facNumDoc,
    super.facNombres,
    super.facApellidoPaterno,
    super.facApellidoMaterno,
    super.historial,
    super.cabecera,
  });

  //  0  NUMSOL
  //  1  ID_TIPO_DOCUMENTO del participante (id crudo, no descripción — se
  //     resuelve contra CatalogsBloc.tiposDocumento en la vista)
  //  2  NUM_DOC_SOL
  //  3  CARGO_SOL
  //  4  CELULAR_SOL
  //  5  CORREO_SOL
  //  6  Tipo de comprobante (descripción, ej. "Factura")
  //  7  NOMEMPRE_FAC (razón social)
  //  8  RUCEMPRE_FAC
  //  9  DIRECCION_FAC
  // 10  NRO_DOCUMENTO_FAC (persona natural — agregado 2026-07-30)
  // 11  NOMBRES_FAC (persona natural — agregado 2026-07-30)
  // 12  APE_PATERNO_FAC (persona natural — agregado 2026-07-30)
  // 13  APE_MATERNO_FAC (persona natural — agregado 2026-07-30)
  factory SolicitudDetalleRealModel.fromRawString(String raw) {
    final secciones = raw.split(AppConstants.sepListas);
    final c = secciones.isNotEmpty
        ? ParseUtils.campos(secciones[0], AppConstants.sepCampos)
        : <String>[];
    final historialRaw = secciones.length > 1 ? secciones[1] : '';
    final cabeceraRaw = secciones.length > 2 ? secciones[2] : '';

    return SolicitudDetalleRealModel(
      numSol: ParseUtils.str(c, 0),
      tipoDocumentoId: ParseUtils.str(c, 1),
      numDoc: ParseUtils.str(c, 2),
      cargo: ParseUtils.str(c, 3),
      celular: ParseUtils.str(c, 4),
      correo: ParseUtils.str(c, 5),
      facTipoComprobante: ParseUtils.str(c, 6),
      facRazonSocial: ParseUtils.str(c, 7),
      facRuc: ParseUtils.str(c, 8),
      facDireccion: ParseUtils.str(c, 9),
      facNumDoc: ParseUtils.str(c, 10),
      facNombres: ParseUtils.str(c, 11),
      facApellidoPaterno: ParseUtils.str(c, 12),
      facApellidoMaterno: ParseUtils.str(c, 13),
      historial: _parseHistorial(historialRaw),
      cabecera: cabeceraRaw.trim().isEmpty
          ? null
          : SolicitudModel.fromRawString(cabeceraRaw),
    );
  }

  static List<HistorialSolicitud> _parseHistorial(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) {
          final c = ParseUtils.campos(r, AppConstants.sepCampos);
          final descripcionSeguimiento = ParseUtils.str(c, 1);
          return HistorialSolicitud(
            origen: ParseUtils.str(c, 2),
            titulo: ParseUtils.str(c, 3),
            descripcion: descripcionSeguimiento.isNotEmpty
                ? descripcionSeguimiento
                : ParseUtils.str(c, 4),
            fecha: ParseUtils.str(c, 5),
          );
        })
        .toList();
  }
}
