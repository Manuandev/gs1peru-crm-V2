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
  final List<Lead> leads;
  final LeadListFiltro filtro;
  final Map<LeadListFiltro, int> conteos;
  // codUser del asesor elegido en el modal cuando filtro == asesores
  final String? asesorSeleccionado;
  // conteo de leads por codUser de asesor, sobre el total cargado (no filtrado)
  final Map<String, int> conteosPorAsesor;

  const LeadListSuccess({
    required this.leads,
    this.filtro = LeadListFiltro.todos,
    this.conteos = const {},
    this.asesorSeleccionado,
    this.conteosPorAsesor = const {},
  });

  @override
  List<Object?> get props => [leads, filtro, asesorSeleccionado];
}

class LeadListError extends LeadListState {
  final String message;
  const LeadListError(this.message);

  @override
  List<Object?> get props => [message];
}
