// lib/core/models/historial_evento.dart
//
// Evento de historial (seguimiento + comentario + recordatorio) — MISMO
// formato en las 4 pantallas con historial (2026-09-14):
//   · Conversaciones y Seguimiento → SP CRM.CSV_LEADS_LST_APP task 'LHC'
//     (todas las negociaciones activas del contacto).
//   · Detalle de Solicitud → CRM.CSV_SOLICITUD_LST_APP task 'DV', sección [3].
//   · Detalle de cobro → CRM.CSV_COBRANZAS_LST_APP task 'DT', sección [3].
//     (estos dos, solo la negociación de esa solicitud).
// Movido desde lead/ para que los 4 usen la misma entidad y el mismo widget
// (AppHistorialEventoItem).

import 'package:app_crm/index_dependencies.dart';

/// Quién generó el evento (columna TIPO_USUARIO del SP): 'ASE' asesor ·
/// 'AIA' bot IA ('SIS' sistema hoy se trata como bot IA).
// enum TipoActor { sistema, botIA, cliente, asesor }
enum TipoActor { botIA, cliente, asesor }

/// Qué tipo de evento es (columna TIPO_EVENTO del SP): 'SEG' seguimiento
/// (CRM.T_LEAD_SEGUIMIENTO) · 'COM' comentario (CRM.T_LEAD_COMENTARIO) ·
/// 'REC' recordatorio (CRM.T_LEAD_RECORDATORIO).
enum TipoEventoHistorial { seguimiento, comentario, recordatorio }

class HistorialComentario extends Equatable {
  final int idLead;
  final int idComentario;
  final String notas;
  final String actividadNombre;
  final String actividadIcono;
  final String actividadColor;
  final String nombreUsuario;
  final String idUsuarioC;
  final String fechaHora;
  final TipoActor tipoActor;
  final TipoEventoHistorial tipoEvento;
  final int idOportunidad;
  final String oportunidad;

  const HistorialComentario({
    required this.idLead,
    required this.idComentario,
    required this.notas,
    required this.actividadNombre,
    required this.actividadIcono,
    required this.actividadColor,
    required this.nombreUsuario,
    required this.idUsuarioC,
    required this.fechaHora,
    required this.tipoActor,
    required this.tipoEvento,
    required this.idOportunidad,
    required this.oportunidad,
  });

  /// Nombre a mostrar como actor: nombre real si existe, si no un label
  /// genérico según el tipo (Bot IA / Sistema no tienen NOMUSER).
  String get actorLabel {
    if (nombreUsuario.isNotEmpty) return nombreUsuario;
    return switch (tipoActor) {
      TipoActor.botIA => 'Bot IA',
      // TipoActor.sistema => 'Sistema',
      TipoActor.cliente => 'Cliente',
      TipoActor.asesor => 'Asesor',
    };
  }

  @override
  List<Object?> get props => [
    idLead,
    idComentario,
    notas,
    actividadNombre,
    actividadIcono,
    actividadColor,
    nombreUsuario,
    idUsuarioC,
    fechaHora,
    tipoActor,
    tipoEvento,
    idOportunidad,
    oportunidad,
  ];
}
