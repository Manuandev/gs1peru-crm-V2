// lib/features/cobranza/data/models/cobranza_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaModel extends Cobranza {
  const CobranzaModel({
    required super.numSol,
    required super.nombre,
    required super.apellido,
    super.apellidoMaterno,
    super.nombreEmpresa,
    super.cargo,
    required super.telefono,
    super.correo,
    super.codTipoPersona,
    super.tipoPersona,
    required super.fecha,
    required super.montoTotal,
    required super.idCondicion,
    required super.condicion,
    required super.ejecutivo,
    super.idEvento,
    required super.evento,
    required super.idEstado,
    required super.estado,
    super.ibValidado,
    required super.asignadoA,
  });

  // idEstadoGes (crudo, [CRM].[CSV_COBRANZAS_LST_APP]) → código interno de la app.
  // DBO.[edu.TIP_ESTADO_GES]: 0=Pend.deDocumento 1=FreePass 2=Facturar
  // 3=Cancelado 4=Anulado 5=Pend.factura.
 

  factory CobranzaModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return CobranzaModel(
      numSol: ParseUtils.str(fields,0),
      nombre: ParseUtils.str(fields,1),
      apellido: ParseUtils.str(fields,2),
      apellidoMaterno: ParseUtils.str(fields,3),
      nombreEmpresa: ParseUtils.str(fields,4),
      cargo: ParseUtils.str(fields,5),
      telefono: ParseUtils.str(fields,6),
      correo: ParseUtils.str(fields,7),
      codTipoPersona: ParseUtils.str(fields,8),
      tipoPersona: ParseUtils.str(fields,9),
      fecha: ParseUtils.str(fields,10),
      montoTotal: ParseUtils.toDouble(fields,11),
      idCondicion: ParseUtils.str(fields,12),
      condicion: ParseUtils.str(fields,13),
      ejecutivo: ParseUtils.str(fields,14),
      idEvento: ParseUtils.toInt(fields,15),
      evento: ParseUtils.str(fields,16),
      idEstado: ParseUtils.toInt(fields,17),
      estado: ParseUtils.str(fields,18),
      ibValidado: ParseUtils.toBool(fields,19),
      asignadoA: ParseUtils.str(fields,20),
    );
  }

  static List<CobranzaModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => CobranzaModel.fromRawString(r))
        .toList();
  }
}
