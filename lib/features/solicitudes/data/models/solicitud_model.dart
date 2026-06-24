// lib/features/solicitudes/data/models/solicitud_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';

class SolicitudModel extends Solicitud {
  const SolicitudModel({
    required super.idSolicitud,
    required super.idContacto,
    required super.nombre,
    required super.apellido,
    required super.nombreEmpresa,
    required super.correo,
    required super.telefono,
    required super.idTipoSolicitud,
    required super.tipoSolicitud,
    required super.idEstado,
    required super.estado,
    required super.asesor,
    required super.nombreAsesor,
    required super.idCanal,
    required super.fechaCreacion,
    required super.monto,
    required super.observaciones,
  });

  factory SolicitudModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return SolicitudModel(
      idSolicitud: ParseUtils.toInt(fields, 0),
      idContacto: ParseUtils.toInt(fields, 1),
      nombre: ParseUtils.str(fields, 2),
      apellido: ParseUtils.str(fields, 3),
      nombreEmpresa: ParseUtils.str(fields, 4),
      correo: ParseUtils.str(fields, 5),
      telefono: ParseUtils.str(fields, 6),
      idTipoSolicitud: ParseUtils.toInt(fields, 7),
      tipoSolicitud: ParseUtils.str(fields, 8),
      idEstado: ParseUtils.str(fields, 9),
      estado: ParseUtils.str(fields, 10),
      asesor: ParseUtils.str(fields, 11),
      nombreAsesor: ParseUtils.str(fields, 12),
      idCanal: ParseUtils.toInt(fields, 13),
      fechaCreacion: ParseUtils.str(fields, 14),
      monto: ParseUtils.toDouble(fields, 15),
      observaciones: ParseUtils.str(fields, 16),
    );
  }

  static List<SolicitudModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => SolicitudModel.fromRawString(r))
        .toList();
  }
}
