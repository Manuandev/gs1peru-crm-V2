// lib/features/lead/presentation/cubit/negociaciones/negociaciones_state.dart

import 'package:app_crm/index_dependencies.dart';

enum AccionNegociacion { seleccionada, verPropuesta, generarSolicitud }

class NegociacionFake {
  final String nombre;
  final String empresa;
  final int idCanal;
  final int cantidad;
  final String ultimaActualizacion;
  final String idEstado;
  final String estado;
  final AccionNegociacion accion;

  const NegociacionFake({
    required this.nombre,
    required this.empresa,
    required this.idCanal,
    required this.cantidad,
    required this.ultimaActualizacion,
    required this.idEstado,
    required this.estado,
    required this.accion,
  });
}

sealed class NegociacionesState extends Equatable {
  const NegociacionesState();

  @override
  List<Object?> get props => [];
}

class NegociacionesInitial extends NegociacionesState {
  const NegociacionesInitial();
}

class NegociacionesLoading extends NegociacionesState {
  const NegociacionesLoading();
}

class NegociacionesSuccess extends NegociacionesState {
  final List<NegociacionFake> negociaciones;

  const NegociacionesSuccess({required this.negociaciones});

  @override
  List<Object?> get props => [negociaciones];
}

class NegociacionesError extends NegociacionesState {
  final String mensaje;

  const NegociacionesError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
