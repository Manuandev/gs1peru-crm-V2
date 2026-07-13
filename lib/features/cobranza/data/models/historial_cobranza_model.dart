// lib/features/cobranza/data/models/historial_cobranza_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

// CRM.T_LEAD_SEGUIMIENTO + CRM.T_LEAD_ACTIVIDAD (historial del lead asociado
// al NUMSOL, ver task 'DT' de CSV_COBRANZAS_LST_APP).
class HistorialCobranzaModel extends HistorialCobranza {
  const HistorialCobranzaModel({
    required super.origen,
    required super.titulo,
    required super.descripcion,
    required super.fecha,
  });

  // Posiciones: 0 idLead (no se usa acá) · 1 LS.DESCRIPCION (seguimiento) ·
  // 2 LA.ORIGEN · 3 LA.NOMBRE · 4 LA.DESCRIPCION (actividad, fallback si el
  // seguimiento no trae texto) · 5 fecha cruda (yyyy-MM-dd HH:mm:ss).
  factory HistorialCobranzaModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    final descripcionSeguimiento = ParseUtils.str(c, 1);
    return HistorialCobranzaModel(
      origen: ParseUtils.str(c, 2),
      titulo: ParseUtils.str(c, 3),
      descripcion: descripcionSeguimiento.isNotEmpty
          ? descripcionSeguimiento
          : ParseUtils.str(c, 4),
      fecha: ParseUtils.str(c, 5),
    );
  }

  static List<HistorialCobranzaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => HistorialCobranzaModel.fromRawString(r))
        .toList();
  }
}
