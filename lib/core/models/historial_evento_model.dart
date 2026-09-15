// lib/core/models/historial_evento_model.dart
//
// Parseo del historial unificado — 11 campos posicionales, igual en los 3
// SPs ('LHC' de leads, sección [3] del 'DV' de solicitudes y del 'DT' de
// cobranzas):
//   0 ID_LEAD · 1 TIPO_EVENTO · 2 ID_EVENTO · 3 DESCRIPCION · 4 ORIGEN ·
//   5 NOMBRE (actividad) · 6 DESCRIPCION_ACTIVIDAD · 7 FC_EVENTO ·
//   8 TIPO_USUARIO · 9 ID_OPORTUNIDAD · 10 NOMBRE_OPORTUNIDAD

import 'package:app_crm/core/index_core.dart';

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
    required super.tipoEvento,
    required super.idOportunidad,
    required super.oportunidad,
  });

  /// Campo 8 (TIPO_USUARIO): 'ASE' asesor · 'SIS' sistema · 'AIA' bot IA.
  static TipoActor _parseTipoActor(List<String> campos) {
    switch (ParseUtils.str(campos, 8).toUpperCase()) {
      case 'ASE':
        return TipoActor.asesor;
      // case 'SIS':
      //   return TipoActor.sistema;
      case 'AIA':
      default:
        return TipoActor.botIA;
    }
  }

  /// Campo 1 (TIPO_EVENTO): 'SEG' seguimiento · 'COM' comentario ·
  /// 'REC' recordatorio.
  static TipoEventoHistorial _parseTipoEvento(List<String> campos) {
    switch (ParseUtils.str(campos, 1).toUpperCase()) {
      case 'COM':
        return TipoEventoHistorial.comentario;
      case 'REC':
        return TipoEventoHistorial.recordatorio;
      case 'SEG':
      default:
        return TipoEventoHistorial.seguimiento;
    }
  }

  factory HistorialComentarioModel.fromRawStringCompleto(String raw) {
    final fields = raw.split(AppConstants.sepCampos);

    return HistorialComentarioModel(
      idLead: ParseUtils.toInt(fields, 0),
      idComentario: ParseUtils.toInt(fields, 2),
      notas: ParseUtils.str(fields, 3),
      actividadNombre: ParseUtils.str(fields, 5),
      actividadIcono: '',
      actividadColor: '',
      nombreUsuario: '',
      idUsuarioC: '',
      fechaHora: ParseUtils.str(fields, 7),
      tipoActor: _parseTipoActor(fields),
      tipoEvento: _parseTipoEvento(fields),
      idOportunidad: ParseUtils.toInt(fields, 9),
      oportunidad: ParseUtils.str(fields, 10),
    );
  }

  static List<HistorialComentarioModel> parseListCompleto(
    String rawResponse,
  ) {
    if (rawResponse.trim().isEmpty) return const [];
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => HistorialComentarioModel.fromRawStringCompleto(r))
        .toList();
  }
}
