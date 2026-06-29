// lib/features/lead/presentation/cubit/negociaciones/negociaciones_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

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
  final List<Negociacion> negociaciones;

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
