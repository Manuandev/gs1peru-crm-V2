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
  // Leads no cerrados (idEstado/idEstadoPadre != '04'), sobre la lista completa sin filtrar
  // por chip — mismo criterio que CSV_HOME_LST_APP.TOT_SEGUIMIENTOS_ACTIVOS, alimenta el
  // badge de "Seguimiento" del drawer en tiempo real mientras esta pantalla está montada.
  final int activos;

  const LeadListSuccess({
    required this.contactos,
    this.filtro = LeadListFiltro.todos,
    this.conteos = const {},
    this.activos = 0,
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
