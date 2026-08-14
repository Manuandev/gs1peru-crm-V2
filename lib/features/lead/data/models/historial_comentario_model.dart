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
    required super.tipoEvento,
    required super.idOportunidad,
    required super.oportunidad,
  });

  /// Campo 8 (TIPO_USUARIO del SP task 'LHC'): 'ASE' asesor · 'SIS' sistema ·
  /// 'AIA' bot IA.
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

  /// Campo 1 (TIPO_EVENTO del SP task 'LHC'): 'SEG' seguimiento · 'COM'
  /// comentario · 'REC' recordatorio.
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

  /// Parseo del SP task 'LHC' — historial unificado (seguimiento + comentario
  /// + recordatorio) de todos los leads activos del contacto.
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
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map((r) => HistorialComentarioModel.fromRawStringCompleto(r))
        .toList();
  }
}
