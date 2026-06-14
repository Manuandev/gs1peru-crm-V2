// lib/features/chat/presentation/bloc/template/select_template_event.dart

import 'package:app_crm/index_dependencies.dart';

abstract class SelectTemplateEvent extends Equatable {
  const SelectTemplateEvent();

  @override
  List<Object?> get props => [];
}

class SelectTemplateStarted extends SelectTemplateEvent {
  const SelectTemplateStarted();
}

class SelectTemplateRefresh extends SelectTemplateEvent {
  const SelectTemplateRefresh();
}
