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

class LeadListLoaded extends LeadListState {
  final List<LeadEntity> leads;
  final LeadType type;

  const LeadListLoaded({required this.leads, required this.type});

  @override
  List<Object?> get props => [leads, type];
}

class LeadListError extends LeadListState {
  final String message;
  const LeadListError(this.message);

  @override
  List<Object?> get props => [message];
}
