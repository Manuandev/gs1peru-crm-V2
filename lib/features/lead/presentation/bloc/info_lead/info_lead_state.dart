// lib/features/lead/presentation/bloc/info_lead/info_lead_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

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
  final Negociacion negociacion;

  const InfoLeadSuccess(this.negociacion);

  @override
  List<Object?> get props => [negociacion];
}

class InfoLeadFailure extends InfoLeadState {
  final String message;
  const InfoLeadFailure(this.message);

  @override
  List<Object?> get props => [message];
}
