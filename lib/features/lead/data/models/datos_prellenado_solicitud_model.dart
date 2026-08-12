// lib/features/lead/data/models/datos_prellenado_solicitud_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class DatosPrellenadoSolicitudModel extends DatosPrellenadoSolicitud {
  const DatosPrellenadoSolicitudModel({
    required super.idLead,
    required super.cantidad,
    required super.precioBase,
    required super.descuento,
    required super.precio,
    required super.idMoneda,
    required super.nombres,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.nombreEmpresa,
    required super.correo,
    required super.celular,
    required super.celularCodigoTelefono,
    required super.ruc,
    required super.cargo,
    required super.tipoDocId,
    required super.numDoc,
  });

  /// Parseo del SP 'NEG' (CRM.CSV_LEADS_LST_APP) — 17 campos posicionales:
  /// 0 idLead, 1 cantidad (IN_PARTICIPANTES), 2 precioBase, 3 descuento,
  /// 4 precio (total), 5 idMoneda, 6 nombres, 7 apellidoPaterno,
  /// 8 apellidoMaterno, 9 nombreEmpresa, 10 correo, 11 celular (número),
  /// 12 celularCodigoTelefono (prefijo país), 13 ruc, 14 cargo, 15 tipoDocId,
  /// 16 numDoc.
  factory DatosPrellenadoSolicitudModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return DatosPrellenadoSolicitudModel(
      idLead: ParseUtils.toInt(fields, 0),
      cantidad: ParseUtils.toInt(fields, 1),
      precioBase: ParseUtils.toDouble(fields, 2),
      descuento: ParseUtils.toDouble(fields, 3),
      precio: ParseUtils.toDouble(fields, 4),
      idMoneda: ParseUtils.str(fields, 5),
      nombres: ParseUtils.str(fields, 6),
      apellidoPaterno: ParseUtils.str(fields, 7),
      apellidoMaterno: ParseUtils.str(fields, 8),
      nombreEmpresa: ParseUtils.str(fields, 9),
      correo: ParseUtils.str(fields, 10),
      celular: ParseUtils.str(fields, 11),
      celularCodigoTelefono: ParseUtils.str(fields, 12),
      ruc: ParseUtils.str(fields, 13),
      cargo: ParseUtils.str(fields, 14),
      tipoDocId: ParseUtils.str(fields, 15),
      numDoc: ParseUtils.str(fields, 16),
    );
  }

  static DatosPrellenadoSolicitudModel? parse(String rawResponse) {
    if (rawResponse.trim().isEmpty) return null;
    return DatosPrellenadoSolicitudModel.fromRawString(rawResponse);
  }
}
