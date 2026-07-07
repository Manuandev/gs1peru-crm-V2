// lib/features/lead/data/models/contacto_model.dart
//
// Parsea la porción de Contacto (T_CONTACTO) de la fila del SP de listado
// (lead_list_page.dart, task 'LS'). Se usa desde ContactoNegociacionModel,
// que reparte los mismos campos entre Contacto/Numero/Negociacion.
// correo/cargo no vienen en este SP — quedan null hasta que la pantalla de
// detalle de contacto los traiga con su propio SP.

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoModel extends Contacto {
  const ContactoModel({
    required super.idContacto,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.nombreEmpresa,
    required super.asesor,
    super.cargo,
    super.correo,
  });

  factory ContactoModel.fromFields(List<String> fields) {
    return ContactoModel(
      // 00 → CT.ID_CONTACTO
      idContacto: ParseUtils.toInt(fields, 0),
      // 01 → CT.NOMBRES
      nombre: ParseUtils.str(fields, 1),
      // 02 → CT.APELLIDO_P
      apellidoPaterno: ParseUtils.str(fields, 2),
      // 03 → CT.APELLIDO_M
      apellidoMaterno: ParseUtils.str(fields, 3),
      // 04 → EM.NOMBRE (empresa)
      nombreEmpresa: ParseUtils.str(fields, 4),
      // 05 → CT.ASESOR_PRINCIPAL
      asesor: ParseUtils.str(fields, 5),
    );
  }
}
