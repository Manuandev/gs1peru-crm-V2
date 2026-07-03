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
  // Asesores distintos presentes en las solicitudes (código, nombre, cantidad)
  final List<AsesorResumen> asesoresDisponibles;

  // Contadores para los indicadores del dashboard (calculados sobre el total)
  final int cntPorCompletar;
  final int cntPorValidar;
  final int cntConDocumentos;
  final int cntListasCobranza;

  const SolicitudListSuccess({
    required this.solicitudes,
    this.filtro = SolicitudFiltro.todas,
    this.asesorSeleccionado,
    this.asesoresDisponibles = const [],
    this.cntPorCompletar = 0,
    this.cntPorValidar = 0,
    this.cntConDocumentos = 0,
    this.cntListasCobranza = 0,
  });

  @override
  List<Object?> get props => [solicitudes, filtro, asesorSeleccionado];
}

/// Resumen de un asesor derivado de las solicitudes cargadas —
/// usado por el modal del chip "Asesores" (ver [SolicitudAsesorPickerModal]).
class AsesorResumen extends Equatable {
  final String cod;
  final String nombre;
  final int cantidad;

  const AsesorResumen({
    required this.cod,
    required this.nombre,
    required this.cantidad,
  });

  @override
  List<Object?> get props => [cod, nombre, cantidad];
}

class SolicitudListError extends SolicitudListState {
  final String message;
  const SolicitudListError(this.message);

  @override
  List<Object?> get props => [message];
}
