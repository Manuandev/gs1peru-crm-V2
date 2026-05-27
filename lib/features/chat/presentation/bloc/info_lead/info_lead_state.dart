// lib\features\chat\presentation\bloc\info_lead\info_lead_state.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

sealed class InfoLeadState extends Equatable {
  const InfoLeadState();

  @override
  List<Object?> get props => [];
}

class InfoLeadInitial extends InfoLeadState {
  const InfoLeadInitial();
}

class InfoLeadLoading extends InfoLeadState {
  const InfoLeadLoading();
}

class InfoLeadSuccess extends InfoLeadState {
  final InfoLead infoLead;
  const InfoLeadSuccess(this.infoLead);

  @override
  List<Object?> get props => [infoLead];
}

class InfoLeadFailure extends InfoLeadState {
  final String message;
  const InfoLeadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
