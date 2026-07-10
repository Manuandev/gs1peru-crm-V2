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

  // Contadores para los indicadores del dashboard (calculados sobre el total).
  // cntSinValidar / cntListasCobranza se basan en `ibValidado` (false/true) —
  // no en `idEstado`. cntConDocumentos sigue basado en `idEstado == '02'`
  // (estado de gestión, dimensión aparte — ver CLAUDE.md del feature)
  final int cntSinValidar;
  final int cntConDocumentos;
  final int cntListasCobranza;

  const SolicitudListSuccess({
    required this.solicitudes,
    this.filtro = SolicitudFiltro.todas,
    this.asesorSeleccionado,
    this.conteosPorAsesor = const {},
    this.cntSinValidar = 0,
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
