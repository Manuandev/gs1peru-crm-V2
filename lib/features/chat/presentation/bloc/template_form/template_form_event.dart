// lib/features/chat/presentation/bloc/template_form/template_form_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/chat/index_chat.dart';

abstract class TemplateFormEvent extends Equatable {
  const TemplateFormEvent();

  @override
  List<Object?> get props => [];
}

class TemplateFormStarted extends TemplateFormEvent {
  final int? idPlantilla; // null = crear, con valor = editar

  const TemplateFormStarted(this.idPlantilla);

  @override
  List<Object?> get props => [idPlantilla];
}

class TemplateFormGuardarPressed extends TemplateFormEvent {
  final Plantilla plantilla;

  const TemplateFormGuardarPressed(this.plantilla);

  @override
  List<Object?> get props => [plantilla];
}
