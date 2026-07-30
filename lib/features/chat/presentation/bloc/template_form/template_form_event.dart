// lib/features/chat/presentation/bloc/template_form/template_form_event.dart

import 'package:app_crm/index_dependencies.dart';

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

// El guardado (con o sin subida de archivo previa) no pasa por un evento —
// ver TemplateFormBloc.guardar(). El resultado (CrudResult) lo necesita la
// vista al toque para decidir si vuelve atrás o se queda mostrando el error
// sin perder lo tipeado, y un evento fire-and-forget no puede devolver nada.
