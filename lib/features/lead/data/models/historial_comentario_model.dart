// lib/features/lead/data/models/historial_comentario_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class HistorialComentarioModel extends HistorialComentario {
  const HistorialComentarioModel({
    required super.idLead,
    required super.idComentario,
    required super.notas,
    required super.actividadNombre,
    required super.actividadIcono,
    required super.actividadColor,
    required super.nombreUsuario,
    required super.idUsuarioC,
    required super.fechaHora,
    required super.tipoActor,
  });

  /// Campo 9 (TIPO_ACTOR): 'ASE' asesor · 'CLI' cliente · 'AIA' bot IA · 'SIS' sistema.
  static TipoActor _parseTipoActor(List<String> campos) {
    switch (ParseUtils.str(campos, 9).toUpperCase()) {
      case 'ASE':
        return TipoActor.asesor;
      case 'CLI':
        return TipoActor.cliente;
      case 'SIS':
        return TipoActor.sistema;
      case 'AIA':
      default:
        return TipoActor.botIA;
    }
  }

  factory HistorialComentarioModel.fromRawString(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return HistorialComentarioModel(
      idLead: ParseUtils.toInt(fields, 0),
      idComentario: ParseUtils.toInt(fields, 1),
      notas: ParseUtils.str(fields, 2),
      actividadNombre: ParseUtils.str(fields, 3),
      actividadIcono: ParseUtils.str(fields, 4),
      actividadColor: ParseUtils.str(fields, 5),
      nombreUsuario: ParseUtils.str(fields, 6),
      idUsuarioC: ParseUtils.str(fields, 7),
      fechaHora: ParseUtils.str(fields, 8),
      tipoActor: _parseTipoActor(fields),
    );
  }

  static List<HistorialComentarioModel> parseList(String rawResponse) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => HistorialComentarioModel.fromRawString(r))
        .toList();
  }

  /// Campo 6 (TIPO_ACTOR del SP 'LH'): 'ASE' asesor · 'SIS' sistema ·
  /// 'AIA' bot IA — este SP no distingue 'CLI' (cliente), a diferencia de 'LCG'.
  static TipoActor _parseTipoActorSeguimiento(List<String> campos) {
    switch (ParseUtils.str(campos, 6).toUpperCase()) {
      case 'ASE':
        return TipoActor.asesor;
      case 'SIS':
        return TipoActor.sistema;
      case 'AIA':
      default:
        return TipoActor.botIA;
    }
  }

  /// Parseo del SP 'LH' (seguimiento de un lead puntual) — trae menos campos
  /// que 'LCG' (sin ícono/color de actividad ni usuario nominal), pero lo
  /// importante (DESCRIPCION y fecha) sí viene.
  factory HistorialComentarioModel.fromRawStringSeguimiento(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return HistorialComentarioModel(
      idLead: ParseUtils.toInt(fields, 0),
      idComentario: 0,
      notas: ParseUtils.str(fields, 1),
      actividadNombre: ParseUtils.str(fields, 3),
      actividadIcono: '',
      actividadColor: '',
      nombreUsuario: '',
      idUsuarioC: '',
      fechaHora: ParseUtils.str(fields, 5),
      tipoActor: _parseTipoActorSeguimiento(fields),
    );
  }

  static List<HistorialComentarioModel> parseListSeguimiento(
    String rawResponse,
  ) {
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => HistorialComentarioModel.fromRawStringSeguimiento(r))
        .toList();
  }
}
