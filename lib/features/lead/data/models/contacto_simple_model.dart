// lib/features/lead/data/models/contacto_simple_model.dart
//
// Parsea la respuesta de CRM.CSV_CONTACTO_LST_APP, task 'DS' (detalle
// simple de contacto — pantalla EditContactoSimple, ver lead/CLAUDE.md).
// Migrado de idNumero a idContacto como ancla (2026-08-03, mismo criterio
// que la migración de CSV_LEADS_LST_APP): el caller siempre llega con un
// idContacto ya resuelto (desde un lead), y anclar en idNumero rompía si el
// contacto no tenía ningún T_CONTACTO_NUMERO activo — el detalle no se
// podía cargar aunque el contacto sí existiera (bug real detectado en
// vivo). Si el contacto no existe (idContacto == 0 o no matchea), el SP
// devuelve '' (ApiEmpty del lado de Flutter) — ver ContactoSimpleModel.vacio.
//
// Secciones separadas por sepListas (¯):
//   [0] datos del contacto (campos separados por ¦):
//       0 idContacto ¦ 1 idNumero (vínculo activo más reciente, 0 si el
//       contacto no tiene ninguno) ¦ 2 idTipoDocumento ¦ 3 numeroDocumento ¦
//       4 idNacionalidad ¦ 5 prefijoContacto (saludo) ¦ 6 nombre ¦
//       7 apellidoPaterno ¦ 8 apellidoMaterno
//   [1] celular del idNumero resuelto arriba (vacío si el contacto no
//       tiene ninguno vinculado): 0 idNumero ¦ 1 prefijoPais ¦ 2 numero
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

  /// Contacto en blanco anclado a [idContacto] — usado cuando el contacto
  /// todavía no existe (pantalla arranca en modo "crear").
  factory ContactoSimpleModel.vacio(int idContacto) =>
      ContactoSimpleModel(idContacto: idContacto);

  factory ContactoSimpleModel.fromRawString(String raw, int idContactoAncla) {
    final secciones = raw.split(AppConstants.sepListas);
    if (secciones.isEmpty || secciones[0].trim().isEmpty) {
      return ContactoSimpleModel.vacio(idContactoAncla);
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
      idNumero: ParseUtils.toInt(fields, 1),
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
