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
    super.correo,
    super.tipoPersona,
    required super.evento,
    super.idEvento,
    required super.montoTotal,
    required super.ejecutivo,
    required super.asignadoA,
    required super.idCondicion,
    required super.condicion,
    required super.fecha,
    super.fechaVencimiento,
    super.diasVencimiento,
    required super.idEstado,
    required super.estado,
    required super.telefono,
  });

  // idEstadoGes (crudo, [CRM].[CSV_COBRANZAS_LST_APP]) → código interno de la app.
  // DBO.[edu.TIP_ESTADO_GES]: 0=Pend.deDocumento 1=FreePass 2=Facturar
  // 3=Cancelado 4=Anulado 5=Pend.factura — solo 0/2/3/5 son parte del flujo
  // de 4 etapas (PD/F/CA/PP); 1 y 4 no tienen bucket propio hoy.
  static const _mapaIdEstado = {
    '0': 'PD',
    '2': 'F',
    '3': 'CA',
    '5': 'PP',
  };

  factory CobranzaModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);
    String f(int i) => i < fields.length ? fields[i].trim() : '';

    final idEstadoGes = f(16);

    return CobranzaModel(
      numSol: f(0),
      nombre: f(1),
      apellido: f(2),
      apellidoMaterno: f(3),
      nombreEmpresa: f(4),
      cargo: f(5),
      telefono: f(6),
      correo: f(7),
      tipoPersona: f(8),
      fecha: f(9),
      montoTotal: double.tryParse(f(10)) ?? 0.0,
      idCondicion: f(11),
      condicion: f(12),
      ejecutivo: f(13),
      idEvento: int.tryParse(f(14)) ?? 0,
      evento: f(15),
      idEstado: _mapaIdEstado[idEstadoGes] ?? idEstadoGes,
      estado: f(17),
      // f(18) = CI.ID_ESTADO_SOL — estado de la solicitud (otra dimensión, no usada aquí)
      asignadoA: f(19),
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
