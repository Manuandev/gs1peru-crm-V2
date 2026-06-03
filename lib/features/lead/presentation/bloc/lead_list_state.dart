// lib\features\lead\presentation\bloc\lead_list_state.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadListState extends Equatable {
  const LeadListState();

  @override
  List<Object?> get props => [];
}

class LeadListInitial extends LeadListState {
  const LeadListInitial();
}

class LeadListLoading extends LeadListState {
  const LeadListLoading();
}

class LeadListSuccess extends LeadListState {
  final List<Lead> leads;
  final LeadType type;
  final LeadListFiltro filtro;
  final Map<LeadListFiltro, int> conteos;

  const LeadListSuccess({
    required this.leads,
    required this.type,
    this.filtro = LeadListFiltro.todos,
    this.conteos = const {},
  });

  @override
  List<Object?> get props => [leads, type];
}

class LeadListError extends LeadListState {
  final String message;
  const LeadListError(this.message);

  @override
  List<Object?> get props => [message];
}
