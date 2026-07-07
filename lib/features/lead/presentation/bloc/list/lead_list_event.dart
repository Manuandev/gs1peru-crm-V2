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

/// Parcha un lead en memoria tras edición exitosa (vía [LeadUpdateNotifier]).
class LeadListLeadUpdated extends LeadListEvent {
  final Negociacion negociacion;
  const LeadListLeadUpdated(this.negociacion);

  @override
  List<Object?> get props => [negociacion];
}
