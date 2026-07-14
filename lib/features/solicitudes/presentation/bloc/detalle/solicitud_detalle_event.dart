// lib/features/solicitudes/presentation/bloc/detalle/solicitud_detalle_event.dart

abstract class SolicitudDetalleEvent {
  const SolicitudDetalleEvent();
}

class SolicitudDetalleStarted extends SolicitudDetalleEvent {
  final String numSol;
  const SolicitudDetalleStarted(this.numSol);
}
