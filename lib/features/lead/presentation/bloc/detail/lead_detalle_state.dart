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

class LeadDetalleLoaded extends LeadDetalleState {
  final LeadDetalle detalle;

  const LeadDetalleLoaded({required this.detalle});

  Lead get lead => detalle.lead;
  List<ComentarioLead> get comentarios => detalle.comentarios;

  List<Object?> get props => [detalle];
}

class LeadDetalleError extends LeadDetalleState {
  final String message;
  const LeadDetalleError(this.message);
}
