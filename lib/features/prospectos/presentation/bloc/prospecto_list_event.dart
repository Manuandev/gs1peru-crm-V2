// lib\features\prospectos\presentation\bloc\prospecto_list_event.dart

import 'package:app_crm/index_dependencies.dart';

abstract class ProspectoListEvent extends Equatable {
  const ProspectoListEvent();

  @override
  List<Object?> get props => [];
}

class ProspectoListStarted extends ProspectoListEvent {
  const ProspectoListStarted();
}

class ProspectoListRefresh extends ProspectoListEvent {
  const ProspectoListRefresh();
}
