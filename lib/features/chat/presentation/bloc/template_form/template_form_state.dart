// lib/features/chat/presentation/bloc/template_form/template_form_state.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

abstract class TemplateFormState extends Equatable {
  const TemplateFormState();

  @override
  List<Object?> get props => [];
}

class TemplateFormInitial extends TemplateFormState {
  const TemplateFormInitial();
}

class TemplateFormLoaded extends TemplateFormState {
  final Plantilla plantilla;

  const TemplateFormLoaded({required this.plantilla});

  @override
  List<Object?> get props => [plantilla];
}

class TemplateFormError extends TemplateFormState {
  final String message;
  const TemplateFormError(this.message);

  @override
  List<Object?> get props => [message];
}
