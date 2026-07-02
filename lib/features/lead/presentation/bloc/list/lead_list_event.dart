// lib/features/lead/presentation/bloc/list/lead_list_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadListEvent extends Equatable {
  const LeadListEvent();

  @override
  List<Object?> get props => [];
}

class LeadListStarted extends LeadListEvent {
  const LeadListStarted();
}

class LeadListRefresh extends LeadListEvent {
  const LeadListRefresh();
}

class LeadListFiltered extends LeadListEvent {
  final LeadListFiltro filtro;
  const LeadListFiltered(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// Se selecciona un asesor específico desde el modal de búsqueda —
/// activa el filtro [LeadListFiltro.asesores] acotado a ese `codUser`.
class LeadListAsesorSeleccionado extends LeadListEvent {
  final String codUser;
  const LeadListAsesorSeleccionado(this.codUser);

  @override
  List<Object?> get props => [codUser];
}

class ToggleFavoritoPressed extends LeadListEvent {
  final int idLead;
  final bool nuevoValor;

  const ToggleFavoritoPressed({required this.idLead, required this.nuevoValor});

  @override
  List<Object?> get props => [idLead, nuevoValor];
}

/// Parcha un lead en memoria tras edición exitosa (vía [LeadUpdateNotifier]).
class LeadListLeadUpdated extends LeadListEvent {
  final Lead lead;
  const LeadListLeadUpdated(this.lead);

  @override
  List<Object?> get props => [lead];
}
