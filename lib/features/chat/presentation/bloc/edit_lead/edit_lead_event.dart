// lib/features/chat/presentation/bloc/edit_lead/edit_lead_event.dart

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
