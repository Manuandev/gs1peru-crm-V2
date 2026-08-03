// lib/features/lead/data/models/contacto_model.dart
//
// Parsea la porción de Contacto (T_CONTACTO) de la fila del SP de listado
// (lead_list_page.dart, task 'LS'). Se usa desde ContactoNegociacionModel,
// que reparte los mismos campos entre Contacto/Numero/Negociacion.
// 'LS' comparte exactamente el mismo layout de columnas que 'DT' (mismo
// SELECT, solo cambia el WHERE) — ver comentario de índices en
// NegociacionModel.fromDetalleRawString. cargo (32) es texto libre
// (T_EMPRESA_CONTACTO.NOM_CARGO, 2026-08-03) — antes salía de CT.ID_CARGO
// (id crudo sin catálogo) y no se parseaba para no mostrar un número donde
// se esperaba un puesto; con el SP corregido ya es seguro parsearlo.

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
      // 01 → CT.ID_CONTACTO
      idContacto: ParseUtils.toInt(fields, 1),
      // 02 → CT.NOMBRES
      nombre: ParseUtils.str(fields, 2),
      // 03 → CT.APELLIDO_P
      apellidoPaterno: ParseUtils.str(fields, 3),
      // 04 → CT.APELLIDO_M
      apellidoMaterno: ParseUtils.str(fields, 4),
      // 05 → EM.NOMBRE (empresa)
      nombreEmpresa: ParseUtils.str(fields, 5),
      // 06 → CT.ASESOR_PRINCIPAL
      asesor: ParseUtils.str(fields, 6),
      // 32 → T_EMPRESA_CONTACTO.NOM_CARGO (texto libre)
      cargo: ParseUtils.strNullable(fields, 32),
      // 12 → CO.CORREO
      correo: ParseUtils.strNullable(fields, 12),
    );
  }
}
