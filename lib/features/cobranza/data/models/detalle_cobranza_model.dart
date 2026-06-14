// lib/features/cobranza/data/models/detalle_cobranza_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaDetalleModel extends CobranzaDetalle {
  const CobranzaDetalleModel({
    required super.idCobranza,
    required super.nombre,
    required super.apellido,
    required super.oportunidad,
    required super.ejecutivo,
    required super.montoTotal,
    required super.idEstado,
    required super.estado,
    required super.idCondicion,
    required super.condicion,
    required super.fechaSolicitud,
    required super.tipoComprobante,
    required super.historial,
  });

  static CobranzaDetalleModel parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final listaRaw = partes.isNotEmpty ? partes[0] : '';
    final historialRaw = partes.length > 1 ? partes[1] : '';

    final c = listaRaw.split(AppConstants.sepCampos);

    final historialCobranza = historialRaw.trim().isEmpty
        ? <HistorialCobranzaModel>[]
        : HistorialCobranzaModel.parseList(historialRaw);

    return CobranzaDetalleModel(
    idCobranza:      ParseUtils.str(c, 0),
    nombre:          ParseUtils.str(c, 1),
    apellido:        ParseUtils.str(c, 2),
    oportunidad:     ParseUtils.str(c, 3),
    ejecutivo:       ParseUtils.str(c, 4),
    montoTotal:      ParseUtils.toDouble(c, 5),
    idEstado:        ParseUtils.toInt(c, 6),
    estado:          ParseUtils.str(c, 7),
    idCondicion:     ParseUtils.toInt(c, 8),
    condicion:       ParseUtils.str(c, 9),
    fechaSolicitud:  ParseUtils.str(c, 10),
    tipoComprobante: ParseUtils.str(c, 11),
      historial: historialCobranza,
    );
  }
}
