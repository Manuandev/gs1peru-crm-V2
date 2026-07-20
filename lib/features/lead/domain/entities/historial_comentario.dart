// lib/features/lead/domain/entities/historial_comentario.dart

import 'package:app_crm/index_dependencies.dart';

/// Quién generó el evento de historial.
///
/// Código esperado en el SP (columna TIPO_ACTOR) — mismo criterio que
/// ChatMessage.direccionMensaje: 'ASE' | 'CLI' | 'AIA' + 'SIS'.
// enum TipoActor { sistema, botIA, cliente, asesor }
enum TipoActor { botIA, cliente, asesor }

/// Evento del historial de seguimiento (CRM.T_LEAD_SEGUIMIENTO) — viene del
/// SP 'LH' (por lead puntual) o 'LHN' (todos los leads activos del mismo
/// número de contacto).
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
  ];
}
