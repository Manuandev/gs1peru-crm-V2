// lib/features/cobranza/data/models/detalle_cobranza_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleModel extends CobranzaDetalle {
  const CobranzaDetalleModel({
    required super.idCobranza,
    required super.nombre,
    required super.apellido,
    super.apellidoMaterno,
    super.idOportunidad,
    required super.oportunidad,
    required super.ejecutivo,
    required super.montoTotal,
    required super.idEstado,
    required super.estado,
    required super.idCondicion,
    required super.condicion,
    required super.fechaSolicitud,
    required super.tipoComprobante,
    super.moneda,
    super.monedaId,
    super.correo,
    super.celular,
    super.idChatCab,
    super.facNumDoc,
    super.facNombres,
    super.facApePaterno,
    super.facApeMaterno,
    super.facRuc,
    super.facRazonSocial,
    super.facDireccion,
    super.archivos,
    required super.historial,
  });

  // Task 'DT' de [CRM].[CSV_COBRANZAS_LST_APP] — 3 secciones separadas por
  // sepListas: [0] campos principales (sepCampos, 26 posiciones) · [1]
  // archivos · [2] historial. Los campos 19-25 (datos de facturación) se
  // agregaron el 2026-09-11 — con el SP viejo llegan vacíos (ParseUtils.str
  // devuelve '' si el índice no existe), la sección simplemente muestra
  // menos filas.
  static CobranzaDetalleModel parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final c = partes.isNotEmpty
        ? ParseUtils.campos(partes[0], AppConstants.sepCampos)
        : <String>[];
    final archivosRaw = partes.length > 1 ? partes[1] : '';
    final historialRaw = partes.length > 2 ? partes[2] : '';

    final archivos = archivosRaw.trim().isEmpty
        ? <ArchivoCobranzaModel>[]
        : ArchivoCobranzaModel.parseList(archivosRaw);

    final historial = historialRaw.trim().isEmpty
        ? <HistorialCobranzaModel>[]
        : HistorialCobranzaModel.parseList(historialRaw);

    return CobranzaDetalleModel(
      idCobranza: ParseUtils.str(c, 0),
      nombre: ParseUtils.str(c, 1),
      apellido: ParseUtils.str(c, 2),
      apellidoMaterno: ParseUtils.str(c, 3),
      celular: ParseUtils.str(c, 4),
      correo: ParseUtils.str(c, 5),
      moneda: ParseUtils.str(c, 6),
      tipoComprobante: ParseUtils.str(c, 7),
      idCondicion: ParseUtils.str(c, 8),
      condicion: ParseUtils.str(c, 9),
      montoTotal: ParseUtils.toDouble(c, 10),
      idEstado: ParseUtils.toInt(c, 11),
      estado: ParseUtils.str(c, 12),
      ejecutivo: ParseUtils.str(c, 13),
      idOportunidad: ParseUtils.toInt(c, 14),
      oportunidad: ParseUtils.str(c, 15),
      fechaSolicitud: ParseUtils.str(c, 16),
      idChatCab: ParseUtils.toInt(c, 17),
      monedaId: ParseUtils.str(c, 18),
      facNumDoc: ParseUtils.str(c, 19),
      facNombres: ParseUtils.str(c, 20),
      facApePaterno: ParseUtils.str(c, 21),
      facApeMaterno: ParseUtils.str(c, 22),
      facRuc: ParseUtils.str(c, 23),
      facRazonSocial: ParseUtils.str(c, 24),
      facDireccion: ParseUtils.str(c, 25),
      archivos: archivos,
      historial: historial,
    );
  }
}
