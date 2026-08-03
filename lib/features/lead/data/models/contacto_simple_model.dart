// lib/features/lead/data/models/contacto_simple_model.dart
//
// Parsea la respuesta de CRM.CSV_CONTACTO_LST_APP, task 'DS' (detalle
// simple de contacto por idNumero — pantalla EditContactoSimple, ver
// lead/CLAUDE.md). Si el número todavía no tiene contacto asociado, el SP
// devuelve '' (ApiEmpty del lado de Flutter) — ver ContactoSimpleModel.vacio.
//
// Secciones separadas por sepListas (¯):
//   [0] datos del contacto (campos separados por ¦):
//       0 idContacto ¦ 1 idNumero ¦ 2 idTipoDocumento ¦ 3 numeroDocumento ¦
//       4 idNacionalidad ¦ 5 prefijoContacto (saludo) ¦ 6 nombre ¦
//       7 apellidoPaterno ¦ 8 apellidoMaterno
//   [1] celular anclado en idNumero (puede venir vacío si el número aún no
//       está en T_NUMERO): 0 idNumero ¦ 1 prefijoPais ¦ 2 numero
//   [2] primer correo activo (puede venir vacío): 0 idCorreo ¦ 1 correo
//   [3] primera empresa vinculada (puede venir vacío):
//       0 idEmpresaContacto ¦ 1 ruc ¦ 2 razonSocial ¦ 3 cargo (texto libre,
//       NOM_CARGO — ya no un id de catálogo)

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoSimpleModel extends ContactoSimple {
  const ContactoSimpleModel({
    super.idContacto,
    super.idNumero,
    super.idTipoDocumento,
    super.numeroDocumento,
    super.idNacionalidad,
    super.prefijoContacto,
    super.nombre,
    super.apellidoPaterno,
    super.apellidoMaterno,
    super.prefijoCelular,
    super.celular,
    super.idCorreo,
    super.correo,
    super.idEmpresaContacto,
    super.ruc,
    super.razonSocial,
    super.cargo,
  });

  /// Contacto en blanco anclado a [idNumero] — usado cuando el número
  /// todavía no tiene contacto asociado (pantalla arranca en modo "crear").
  factory ContactoSimpleModel.vacio(int idNumero) =>
      ContactoSimpleModel(idNumero: idNumero);

  factory ContactoSimpleModel.fromRawString(String raw, int idNumeroAncla) {
    final secciones = raw.split(AppConstants.sepListas);
    if (secciones.isEmpty || secciones[0].trim().isEmpty) {
      return ContactoSimpleModel.vacio(idNumeroAncla);
    }

    final fields = ParseUtils.campos(secciones[0], AppConstants.sepCampos);

    final numeroFields = secciones.length > 1 && secciones[1].trim().isNotEmpty
        ? ParseUtils.campos(secciones[1], AppConstants.sepCampos)
        : const <String>[];
    final correoFields = secciones.length > 2 && secciones[2].trim().isNotEmpty
        ? ParseUtils.campos(secciones[2], AppConstants.sepCampos)
        : const <String>[];
    final empresaFields = secciones.length > 3 && secciones[3].trim().isNotEmpty
        ? ParseUtils.campos(secciones[3], AppConstants.sepCampos)
        : const <String>[];

    return ContactoSimpleModel(
      idContacto: ParseUtils.toInt(fields, 0),
      idNumero: idNumeroAncla,
      idTipoDocumento: ParseUtils.str(fields, 2),
      numeroDocumento: ParseUtils.str(fields, 3),
      idNacionalidad: ParseUtils.str(fields, 4),
      prefijoContacto: ParseUtils.str(fields, 5),
      nombre: ParseUtils.str(fields, 6),
      apellidoPaterno: ParseUtils.str(fields, 7),
      apellidoMaterno: ParseUtils.str(fields, 8),
      prefijoCelular: ParseUtils.str(numeroFields, 1),
      celular: ParseUtils.str(numeroFields, 2),
      idCorreo: ParseUtils.toInt(correoFields, 0),
      correo: ParseUtils.str(correoFields, 1),
      idEmpresaContacto: ParseUtils.toInt(empresaFields, 0),
      ruc: ParseUtils.str(empresaFields, 1),
      razonSocial: ParseUtils.str(empresaFields, 2),
      cargo: ParseUtils.str(empresaFields, 3),
    );
  }
}
