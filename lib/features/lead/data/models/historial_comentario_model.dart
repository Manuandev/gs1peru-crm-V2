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

  /// Campo 6 (TIPO_ACTOR de los SP 'LH'/'LHN'): 'ASE' asesor · 'SIS' sistema ·
  /// 'AIA' bot IA.
  static TipoActor _parseTipoActorSeguimiento(List<String> campos) {
    switch (ParseUtils.str(campos, 6).toUpperCase()) {
      case 'ASE':
        return TipoActor.asesor;
      // case 'SIS':
      //   return TipoActor.sistema;
      case 'AIA':
      default:
        return TipoActor.botIA;
    }
  }

  /// Parseo de los SP 'LH' (por lead) y 'LHN' (por número) — mismo layout de
  /// columnas en ambos, sin ícono/color de actividad ni usuario nominal.
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
