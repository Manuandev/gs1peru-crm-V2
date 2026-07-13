// lib/features/cobranza/data/models/archivo_cobranza_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class ArchivoCobranzaModel extends ArchivoCobranza {
  const ArchivoCobranzaModel({
    required super.tipo,
    required super.archivoId,
    required super.nombre,
    required super.extension,
  });

  factory ArchivoCobranzaModel.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return ArchivoCobranzaModel(
      tipo: ParseUtils.str(c, 0),
      archivoId: ParseUtils.str(c, 1),
      nombre: ParseUtils.str(c, 2),
      extension: ParseUtils.str(c, 3),
    );
  }

  static List<ArchivoCobranzaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => ArchivoCobranzaModel.fromRawString(r))
        .toList();
  }
}
