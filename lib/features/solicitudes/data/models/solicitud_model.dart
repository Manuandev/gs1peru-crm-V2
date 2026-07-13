// lib/features/solicitudes/data/models/solicitud_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';

class SolicitudModel extends Solicitud {
  const SolicitudModel({
    required super.idSolicitud,
    required super.nombre,
    required super.apellidoPaterno,
    required super.apellidoMaterno,
    required super.nombreEmpresa,
    required super.cargo,
    required super.correo,
    required super.telefono,
    required super.tipoPersona,
    required super.idCondicionPago,
    required super.condicionPago,
    required super.monto,
    required super.fechaCreacion,
    required super.idOportunidad,
    required super.oportunidad,
    required super.idCanal,
    required super.canal,
    required super.idEstado,
    required super.estado,
    required super.ibValidado,
    required super.asesor,
    required super.nombreAsesor,
  });

  // Mapeo posicional — [CRM].[CSV_SOLICITUDES_LST_APP], separados por ¦:
  // 0 numsol · 1 nombres · 2 apePaterno · 3 apeMaterno · 4 nomEmpre · 5 cargo ·
  // 6 celular · 7 correo · 8 tipoPersona · 9 idCondicionPago · 10 condicionPago ·
  // 11 impTotal · 12 fecha (últ. actualización, o creación si nunca se modificó) ·
  // 13 FC_USUARIO_C (no se usa, ver nota abajo) · 14 idOportunidad ·
  // 15 nombreOportunidad · 16 idCanal · 17 canal · 18 idEstadoGes ·
  // 19 descripción estado · 20 ibValidado · 21 idUsuarioEjec · 22 nomUser.
  // Ojo: las posiciones 16/17 (canal) dependen de que el SP seleccione
  // CN.ID_CANAL/CN.DESCRIPCION en vez de repetir EG.ID_ESTADO_GES/DESCRIPCION
  // (bug actual) — ver notas del CLAUDE.md de este feature. El índice 13 se
  // deja sin leer a propósito para no desalinear el resto de posiciones.
  factory SolicitudModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return SolicitudModel(
      idSolicitud: ParseUtils.str(fields, 0),
      nombre: ParseUtils.str(fields, 1),
      apellidoPaterno: ParseUtils.str(fields, 2),
      apellidoMaterno: ParseUtils.str(fields, 3),
      nombreEmpresa: ParseUtils.str(fields, 4),
      cargo: ParseUtils.str(fields, 5),
      telefono: ParseUtils.str(fields, 6),
      correo: ParseUtils.str(fields, 7),
      tipoPersona: ParseUtils.str(fields, 8),
      idCondicionPago: ParseUtils.str(fields, 9),
      condicionPago: ParseUtils.str(fields, 10),
      monto: ParseUtils.toDouble(fields, 11),
      fechaCreacion: ParseUtils.str(fields, 12),
      idOportunidad: ParseUtils.toInt(fields, 14),
      oportunidad: ParseUtils.str(fields, 15),
      idCanal: ParseUtils.toInt(fields, 16),
      canal: ParseUtils.str(fields, 17),
      idEstado: ParseUtils.str(fields, 18),
      estado: ParseUtils.str(fields, 19),
      ibValidado: ParseUtils.toBool(fields, 20),
      asesor: ParseUtils.str(fields, 21),
      nombreAsesor: ParseUtils.str(fields, 22),
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
