// lib/features/solicitudes/presentation/bloc/list/solicitud_list_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

abstract class SolicitudListState extends Equatable {
  const SolicitudListState();

  @override
  List<Object?> get props => [];
}

class SolicitudListInitial extends SolicitudListState {
  const SolicitudListInitial();
}

class SolicitudListLoading extends SolicitudListState {
  const SolicitudListLoading();
}

class SolicitudListSuccess extends SolicitudListState {
  final List<Solicitud> solicitudes;
  final SolicitudFiltro filtro;

  // Asesor elegido en SolicitudAsesorPickerModal (chip "Asesores")
  final String? asesorSeleccionado;

  // Conteo de solicitudes por asesor (codUser), calculado sobre _allSolicitudes
  // — alimenta SolicitudAsesorPickerModal (universo de asesores viene de
  // CatalogsBloc, no de este mapa), no viene del backend
  final Map<String, int> conteosPorAsesor;

  // Contadores para los indicadores del dashboard (calculados sobre el total)
  final int cntPorCompletar;
  final int cntPorValidar;
  final int cntConDocumentos;
  final int cntListasCobranza;

  const SolicitudListSuccess({
    required this.solicitudes,
    this.filtro = SolicitudFiltro.todas,
    this.asesorSeleccionado,
    this.conteosPorAsesor = const {},
    this.cntPorCompletar = 0,
    this.cntPorValidar = 0,
    this.cntConDocumentos = 0,
    this.cntListasCobranza = 0,
  });

  @override
  List<Object?> get props => [solicitudes, filtro, asesorSeleccionado];
}

class SolicitudListError extends SolicitudListState {
  final String message;
  const SolicitudListError(this.message);

  @override
  List<Object?> get props => [message];
}
