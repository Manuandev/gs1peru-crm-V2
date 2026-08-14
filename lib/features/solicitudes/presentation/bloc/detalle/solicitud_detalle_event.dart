// lib/features/solicitudes/presentation/bloc/detalle/solicitud_detalle_event.dart

import 'package:app_crm/features/solicitudes/presentation/utils/solicitud_update_notifier.dart';

abstract class SolicitudDetalleEvent {
  const SolicitudDetalleEvent();
}

class SolicitudDetalleStarted extends SolicitudDetalleEvent {
  final String numSol;
  const SolicitudDetalleStarted(this.numSol);
}

// Llega desde SolicitudUpdateNotifier tras guardar el wizard sobre esta
// misma solicitud — parchea el detalle en memoria, sin volver a pedir nada
// al backend.
class SolicitudDetalleItemActualizado extends SolicitudDetalleEvent {
  final SolicitudUpdate update;
  const SolicitudDetalleItemActualizado(this.update);
}
