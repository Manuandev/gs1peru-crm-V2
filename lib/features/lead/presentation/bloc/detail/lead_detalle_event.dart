// lib/features/lead/presentation/bloc/detail/lead_detalle_event.dart

abstract class LeadDetalleEvent {
  const LeadDetalleEvent();
}

class LeadDetalleStarted extends LeadDetalleEvent {
  final int idLead;
  const LeadDetalleStarted(this.idLead);
}
