// lib\features\chat\presentation\bloc\templates\templates_event.dart

import 'package:app_crm/index_dependencies.dart';

abstract class TemplatesEvent extends Equatable {
  const TemplatesEvent();

  @override
  List<Object?> get props => [];
}

class TemplatesStarted extends TemplatesEvent {
  const TemplatesStarted();
}

class TemplatesRefresh extends TemplatesEvent {
  const TemplatesRefresh();
}
