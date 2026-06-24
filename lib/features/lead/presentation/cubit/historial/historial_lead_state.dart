// lib/features/lead/presentation/cubit/historial/historial_lead_state.dart

import 'package:app_crm/index_dependencies.dart';

enum TipoActor { sistema, botIA, cliente, asesor }

class HistorialItemFake {
  final String descripcion;
  final String fechaHora;
  final TipoActor tipoActor;
  final String actor;

  const HistorialItemFake({
    required this.descripcion,
    required this.fechaHora,
    required this.tipoActor,
    required this.actor,
  });
}

sealed class HistorialLeadState extends Equatable {
  const HistorialLeadState();

  @override
  List<Object?> get props => [];
}

class HistorialLeadInitial extends HistorialLeadState {
  const HistorialLeadInitial();
}

class HistorialLeadLoading extends HistorialLeadState {
  const HistorialLeadLoading();
}

class HistorialLeadSuccess extends HistorialLeadState {
  final List<HistorialItemFake> eventos;

  const HistorialLeadSuccess({required this.eventos});

  @override
  List<Object?> get props => [eventos];
}

class HistorialLeadError extends HistorialLeadState {
  final String mensaje;

  const HistorialLeadError({required this.mensaje});

  @override
  List<Object?> get props => [mensaje];
}
