// lib/features/lead/presentation/cubit/historial/historial_lead_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

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
  final List<HistorialComentario> eventos;

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
