// lib/features/lead/data/models/numero_contacto_model.dart
//
// Parsea una fila de la sección "numeros" de CRM.CSV_CONTACTO_LST_APP task
// 'D' (ver contacto_detalle_model.dart). "activo" = T_CONTACTO_NUMERO.
// IB_ACTIVO (el vínculo con el contacto), no T_NUMERO.IB_ACTIVO.
// Fila: idNumero¦prefijo¦numero¦esPrincipal(0/1)¦esFavorito(0/1)¦activo(0/1)

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class NumeroContactoModel extends NumeroContacto {
  const NumeroContactoModel({
    super.idNumero,
    super.prefijo,
    super.numero,
    super.esPrincipal,
    super.esFavorito,
    super.activo,
  });

  factory NumeroContactoModel.fromRawString(String raw) {
    final fields = ParseUtils.campos(raw, AppConstants.sepCampos);
    return NumeroContactoModel(
      idNumero: ParseUtils.toInt(fields, 0),
      prefijo: ParseUtils.str(fields, 1),
      numero: ParseUtils.str(fields, 2),
      esPrincipal: ParseUtils.toBool(fields, 3),
      esFavorito: ParseUtils.toBool(fields, 4),
      activo: fields.length > 5 ? ParseUtils.toBool(fields, 5) : true,
    );
  }

  static List<NumeroContactoModel> parseList(String rawSeccion) {
    return rawSeccion
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => NumeroContactoModel.fromRawString(r))
        .toList();
  }
}
