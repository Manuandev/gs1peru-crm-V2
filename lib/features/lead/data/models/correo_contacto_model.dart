// lib/features/lead/data/models/correo_contacto_model.dart
//
// Parsea una fila de la sección "correos" de CRM.CSV_CONTACTO_LST_APP task
// 'D' (ver contacto_detalle_model.dart).
// Fila: idCorreo¦correo¦activo(0/1)

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class CorreoContactoModel extends CorreoContacto {
  const CorreoContactoModel({super.idCorreo, super.correo, super.activo});

  factory CorreoContactoModel.fromRawString(String raw) {
    final fields = ParseUtils.campos(raw, AppConstants.sepCampos);
    return CorreoContactoModel(
      idCorreo: ParseUtils.toInt(fields, 0),
      correo: ParseUtils.str(fields, 1),
      activo: fields.length > 2 ? ParseUtils.toBool(fields, 2) : true,
    );
  }

  static List<CorreoContactoModel> parseList(String rawSeccion) {
    return rawSeccion
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => CorreoContactoModel.fromRawString(r))
        .toList();
  }
}
