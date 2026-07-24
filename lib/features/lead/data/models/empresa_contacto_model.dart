// lib/features/lead/data/models/empresa_contacto_model.dart
//
// Parsea una fila de la sección "empresas" de CRM.CSV_CONTACTO_LST_APP task
// 'D' (ver contacto_detalle_model.dart). razonSocial repite el mismo valor
// que nombreEmpresa — T_EMPRESA solo tiene una columna NOMBRE, no hay
// "razón social" separada en la tabla real. area/cargo son IDs de catálogo
// (T_EMPRESA_CONTACTO.ID_AREA/ID_CARGO, INT) — el cliente los matchea
// contra CatalogsBloc.areas/cargos (AreaItem/CargoItem, partes [18]/[19]
// del SP lstListas) en EditContactoPortrait._inicializarCombos.
// idDepartamento/idProvincia/idDistrito salen de partir T_EMPRESA.UBIGEO
// (2+2+2) del lado del SP, igual que el ubigeo del contacto.
// Fila: idEmpresaContacto¦idEmpresa¦nombreEmpresa¦idPais¦ruc¦razonSocial¦direccion¦area¦cargo¦idDpto¦idProv¦idDis

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class EmpresaContactoModel extends EmpresaContacto {
  const EmpresaContactoModel({
    super.idEmpresaContacto,
    super.idEmpresa,
    super.nombreEmpresa,
    super.idPais,
    super.ruc,
    super.razonSocial,
    super.direccion,
    super.area,
    super.cargo,
    super.idDepartamento,
    super.idProvincia,
    super.idDistrito,
  });

  factory EmpresaContactoModel.fromRawString(String raw) {
    final fields = ParseUtils.campos(raw, AppConstants.sepCampos);
    return EmpresaContactoModel(
      idEmpresaContacto: ParseUtils.toInt(fields, 0),
      idEmpresa: ParseUtils.toInt(fields, 1),
      nombreEmpresa: ParseUtils.str(fields, 2),
      idPais: ParseUtils.str(fields, 3),
      ruc: ParseUtils.str(fields, 4),
      razonSocial: ParseUtils.str(fields, 5),
      direccion: ParseUtils.str(fields, 6),
      area: ParseUtils.str(fields, 7),
      cargo: ParseUtils.str(fields, 8),
      idDepartamento: ParseUtils.str(fields, 9),
      idProvincia: ParseUtils.str(fields, 10),
      idDistrito: ParseUtils.str(fields, 11),
    );
  }

  static List<EmpresaContactoModel> parseList(String rawSeccion) {
    return rawSeccion
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => EmpresaContactoModel.fromRawString(r))
        .toList();
  }
}
