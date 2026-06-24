// lib/features/solicitudes/presentation/bloc/list/solicitud_list_event.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

abstract class SolicitudListEvent extends Equatable {
  const SolicitudListEvent();

  @override
  List<Object?> get props => [];
}

class SolicitudListStarted extends SolicitudListEvent {
  const SolicitudListStarted();
}

class SolicitudListRefresh extends SolicitudListEvent {
  const SolicitudListRefresh();
}

class SolicitudListFiltered extends SolicitudListEvent {
  final SolicitudFiltro filtro;
  const SolicitudListFiltered(this.filtro);

  @override
  List<Object?> get props => [filtro];
}
