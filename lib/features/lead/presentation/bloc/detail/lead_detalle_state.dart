// lib/features/lead/presentation/bloc/detail/lead_detalle_state.dart

import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadDetalleState {
  const LeadDetalleState();
}

class LeadDetalleInitial extends LeadDetalleState {
  const LeadDetalleInitial();
}

class LeadDetalleLoading extends LeadDetalleState {
  const LeadDetalleLoading();
}

class LeadDetalleSuccess extends LeadDetalleState {
  final LeadDetalleCompleto detalle;
  final List<ComentarioLead> comentarios;

  const LeadDetalleSuccess({
    required this.detalle,
    required this.comentarios,
  });
}

class LeadDetalleError extends LeadDetalleState {
  final String mensaje;
  const LeadDetalleError(this.mensaje);
}
