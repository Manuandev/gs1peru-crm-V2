// lib/features/solicitudes/domain/entities/evento_fecha.dart

import 'package:app_crm/index_dependencies.dart';

// Una fecha de asistencia de EVT.T_EVENTO_FECHA, para el evento vinculado a
// la oportunidad+campaña de una solicitud (task 'EVF' de
// CRM.CSV_SOLICITUD_LST_APP). Lista vacía = esa oportunidad+campaña no tiene
// ningún EVT.T_EVENTO — ver "Fechas de asistencia (Nuevo participante)" en
// solicitudes/CLAUDE.md.
class EventoFechaItem extends Equatable {
  final int idFecha;
  final DateTime fecha;

  const EventoFechaItem({required this.idFecha, required this.fecha});

  @override
  List<Object?> get props => [idFecha, fecha];
}

extension EventoFechasX on List<EventoFechaItem> {
  /// Id del primer día (fecha más temprana) del evento — el que se marca por
  /// defecto a todo participante nuevo (formulario, carga masiva, switch "El
  /// solicitante será participante"). null si el evento no tiene fechas.
  int? get idPrimeraFecha {
    if (isEmpty) return null;
    // Recorrido manual en vez de reduce(): la lista real suele ser
    // List<EventoFechaModel> y reduce() exige que la función sea del tipo
    // exacto de la lista — con EventoFechaItem revienta en tiempo de ejecución.
    EventoFechaItem primera = first;
    for (final f in this) {
      if (f.fecha.isBefore(primera.fecha)) primera = f;
    }
    return primera.idFecha;
  }
}
