// lib/features/lead/domain/entities/historial_comentario.dart

import 'package:app_crm/index_dependencies.dart';

/// Quién generó el evento de historial.
///
/// Código esperado en el SP (columna TIPO_ACTOR) — mismo criterio que
/// ChatMessage.direccionMensaje: 'ASE' | 'CLI' | 'AIA' + 'SIS'.
// enum TipoActor { sistema, botIA, cliente, asesor }
enum TipoActor { botIA, cliente, asesor }

/// Qué tipo de evento es (columna TIPO_EVENTO del SP, task 'LHC'):
/// 'SEG' seguimiento (CRM.T_LEAD_SEGUIMIENTO) · 'COM' comentario
/// (CRM.T_LEAD_COMENTARIO) · 'REC' recordatorio (CRM.T_LEAD_RECORDATORIO).
enum TipoEventoHistorial { seguimiento, comentario, recordatorio }

/// Evento del historial de un contacto — viene del SP task 'LHC' (todos los
/// leads activos del mismo contacto: seguimiento + comentario +
/// recordatorio, unidos y ordenados por fecha).
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
