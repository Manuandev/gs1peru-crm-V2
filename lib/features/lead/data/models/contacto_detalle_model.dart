// lib/features/lead/data/models/contacto_detalle_model.dart
//
// Parsea la respuesta de CRM.CSV_CONTACTO_LST_APP, task 'D' (detalle de
// contacto por idNumero) — formato confirmado contra el .sql real
// (D:\Proyectos\NatCodee\NC.SQLChangeLock\DBEAN\StoredProcedures\
// CRM.CSV_CONTACTO_LST_APP.sql, 2026-07-23). Si el número todavía no tiene
// contacto asociado, el SP devuelve '' (ApiEmpty del lado de Flutter) — ver
// ContactoDetalleModel.vacio.
//
// Secciones separadas por sepListas (¯):
//   [0] datos del contacto (campos separados por ¦):
//       0 idContacto ¦ 1 idNumero ¦ 2 prefijoContacto ¦ 3 linkedin ¦
//       4 idTipoDocumento ¦ 5 numeroDocumento ¦ 6 idNacionalidad ¦
//       7 nombre ¦ 8 apellidoPaterno ¦ 9 apellidoMaterno ¦ 10 idPais ¦
//       11 idDepartamento ¦ 12 idProvincia ¦ 13 idDistrito ¦ 14 direccion
//       (11-13 salen de partir CT.UBIGEO VARCHAR(6) en 2+2+2 del lado del SP)
//   [1] números — filas separadas por ¬ (ver NumeroContactoModel)
//   [2] correos — filas separadas por ¬ (ver CorreoContactoModel)
//   [3] empresas — filas separadas por ¬ (ver EmpresaContactoModel)

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ContactoDetalleModel extends ContactoDetalle {
  const ContactoDetalleModel({
    super.idContacto,
    super.idNumero,
    super.prefijoContacto,
    super.linkedin,
    super.idTipoDocumento,
    super.numeroDocumento,
    super.idNacionalidad,
    super.nombre,
    super.apellidoPaterno,
    super.apellidoMaterno,
    super.idPais,
    super.idDepartamento,
    super.idProvincia,
    super.idDistrito,
    super.direccion,
    super.numeros,
    super.correos,
    super.empresas,
  });

  /// Contacto en blanco anclado a [idNumero] — usado cuando el número
  /// todavía no tiene contacto asociado (pantalla arranca en modo "crear").
  factory ContactoDetalleModel.vacio(int idNumero) =>
      ContactoDetalleModel(idNumero: idNumero);

  factory ContactoDetalleModel.fromRawString(String raw, int idNumeroAncla) {
    final secciones = raw.split(AppConstants.sepListas);
    if (secciones.isEmpty || secciones[0].trim().isEmpty) {
      return ContactoDetalleModel.vacio(idNumeroAncla);
    }

    final fields = ParseUtils.campos(secciones[0], AppConstants.sepCampos);
    final numeros = secciones.length > 1
        ? NumeroContactoModel.parseList(secciones[1])
        : <NumeroContactoModel>[];
    final correos = secciones.length > 2
        ? CorreoContactoModel.parseList(secciones[2])
        : <CorreoContactoModel>[];
    final empresas = secciones.length > 3
        ? EmpresaContactoModel.parseList(secciones[3])
        : <EmpresaContactoModel>[];

    return ContactoDetalleModel(
      idContacto: ParseUtils.toInt(fields, 0),
      idNumero: idNumeroAncla,
      prefijoContacto: ParseUtils.str(fields, 2),
      linkedin: ParseUtils.str(fields, 3),
      idTipoDocumento: ParseUtils.str(fields, 4),
      numeroDocumento: ParseUtils.str(fields, 5),
      idNacionalidad: ParseUtils.str(fields, 6),
      nombre: ParseUtils.str(fields, 7),
      apellidoPaterno: ParseUtils.str(fields, 8),
      apellidoMaterno: ParseUtils.str(fields, 9),
      idPais: ParseUtils.str(fields, 10),
      idDepartamento: ParseUtils.str(fields, 11),
      idProvincia: ParseUtils.str(fields, 12),
      idDistrito: ParseUtils.str(fields, 13),
      direccion: ParseUtils.str(fields, 14),
      numeros: numeros,
      correos: correos,
      empresas: empresas,
    );
  }
}
