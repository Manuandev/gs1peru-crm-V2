// lib\features\lead\presentation\bloc\lead_list_state.dart
// ============================================================
// LeadList - ESTADOS
// ============================================================
//
// FLUJO:
// LeadListInitial → LeadListLoading → LeadListLoaded
//                          └→ LeadListError (botón reintentar)
// ============================================================

import 'package:app_crm/features/lead/index_lead.dart';
import 'package:equatable/equatable.dart';

abstract class LeadListState  extends Equatable {
  const LeadListState ();

  @override
  List<Object?> get props => [];
}

class LeadListInitial extends LeadListState  {
  const LeadListInitial();
}

class LeadListLoading extends LeadListState  {
  const LeadListLoading();
}

class LeadListLoaded extends LeadListState  {
  final List<Lead> leads; // Leads cargados exitosamente

  const LeadListLoaded({ required this.leads});

}

class LeadListError extends LeadListState  {
  final String message;
  const LeadListError(this.message);

  @override
  List<Object?> get props => [message];
}
