// lib/features/recordatorios/presentation/bloc/recordatorios_state.dart
// ============================================================
// Recordatorios - ESTADOS
// ============================================================
//
// FLUJO:
// RecordatoriosInitial → RecordatoriosLoading → RecordatoriosLoaded
//                          └→ RecordatoriosError (botón reintentar)
// ============================================================

import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';
import 'package:equatable/equatable.dart';

abstract class RecordatoriosState extends Equatable {
  const RecordatoriosState();

  @override
  List<Object?> get props => [];
}

class RecordatoriosInitial extends RecordatoriosState {
  const RecordatoriosInitial();
}

class RecordatoriosLoading extends RecordatoriosState {
  const RecordatoriosLoading();
}

class RecordatoriosLoaded extends RecordatoriosState {
  final List<RecordatorioItem> recordatorios;

  const RecordatoriosLoaded({ required this.recordatorios});

}

class RecordatoriosError extends RecordatoriosState {
  final String message;
  const RecordatoriosError(this.message);

  @override
  List<Object?> get props => [message];
}
