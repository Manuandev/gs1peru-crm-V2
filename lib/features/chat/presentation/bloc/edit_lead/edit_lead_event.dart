// lib\features\chat\presentation\bloc\templates\templates_event.dart

import 'package:app_crm/index_dependencies.dart';

abstract class EditLeadEvent extends Equatable {
  const EditLeadEvent();

  @override
  List<Object?> get props => [];
}

class EditLeadStarted extends EditLeadEvent {
  const EditLeadStarted();
}

class EditLeadRefresh extends EditLeadEvent {
  const EditLeadRefresh();
}
