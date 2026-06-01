// lib\features\chat\presentation\bloc\templates\templates_state.dart

import 'package:app_crm/index_dependencies.dart';

abstract class TemplatesState extends Equatable {
  const TemplatesState();

  @override
  List<Object?> get props => [];
}

class TemplatesInitial extends TemplatesState {
  const TemplatesInitial();
}

class TemplatesLoading extends TemplatesState {
  const TemplatesLoading();
}

class TemplatesLoaded extends TemplatesState {
  const TemplatesLoaded();

  @override
  List<Object?> get props => [];
}

class TemplatesError extends TemplatesState {
  final String message;
  const TemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}
