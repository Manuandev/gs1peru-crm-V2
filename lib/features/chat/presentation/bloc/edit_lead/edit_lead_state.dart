// lib\features\chat\presentation\bloc\templates\templates_state.dart

import 'package:app_crm/index_dependencies.dart';

abstract class EditLeadState extends Equatable {
  const EditLeadState();

  @override
  List<Object?> get props => [];
}

class EditLeadInitial extends EditLeadState {
  const EditLeadInitial();
}

class EditLeadLoading extends EditLeadState {
  const EditLeadLoading();
}

class EditLeadLoaded extends EditLeadState {
  const EditLeadLoaded();

  @override
  List<Object?> get props => [];
}

class EditLeadError extends EditLeadState {
  final String message;
  const EditLeadError(this.message);

  @override
  List<Object?> get props => [message];
}
