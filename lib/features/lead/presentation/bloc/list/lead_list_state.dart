// lib/features/lead/presentation/bloc/list/lead_list_state.dart

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
  final List<ContactoNegociacion> contactos;
  final LeadListFiltro filtro;
  final Map<LeadListFiltro, int> conteos;

  const LeadListSuccess({
    required this.contactos,
    this.filtro = LeadListFiltro.todos,
    this.conteos = const {},
  });

  @override
  List<Object?> get props => [contactos, filtro];
}

class LeadListError extends LeadListState {
  final String message;
  const LeadListError(this.message);

  @override
  List<Object?> get props => [message];
}
