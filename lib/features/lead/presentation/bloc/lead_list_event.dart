// lib\features\reminder\presentation\bloc\reminder_list_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadListEvent extends Equatable {
  const LeadListEvent();

  @override
  List<Object?> get props => [];
}

class LeadListStarted extends LeadListEvent {
  final LeadType type;
  const LeadListStarted(this.type);

  @override
  List<Object?> get props => [type];
}

class LeadListRefresh extends LeadListEvent {
  final LeadType type;
  const LeadListRefresh(this.type);

  @override
  List<Object?> get props => [type];
}
