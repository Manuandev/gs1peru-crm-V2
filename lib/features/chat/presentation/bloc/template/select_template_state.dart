// lib\features\chat\presentation\bloc\templates\templates_state.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

abstract class SelectTemplateState extends Equatable {
  const SelectTemplateState();

  @override
  List<Object?> get props => [];
}

class SelectTemplateInitial extends SelectTemplateState {
  const SelectTemplateInitial();
}

class SelectTemplateLoading extends SelectTemplateState {
  const SelectTemplateLoading();
}

class SelectTemplateLoaded extends SelectTemplateState {
  final List<Template> templates;

  const SelectTemplateLoaded({required this.templates});

  @override
  List<Object?> get props => [templates];
}

class SelectTemplateError extends SelectTemplateState {
  final String message;
  const SelectTemplateError(this.message);

  @override
  List<Object?> get props => [message];
}
