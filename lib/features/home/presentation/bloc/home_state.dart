// lib/features/home/presentation/bloc/home_state.dart
// ============================================================
// HOME - ESTADOS
// ============================================================
//
// FLUJO:
// HomeInitial → HomeLoading → HomeLoaded
//                          └→ HomeError (botón reintentar)
// ============================================================

import 'package:app_crm/core/database/models/user_model.dart';
import 'package:app_crm/features/home/data/models/lead_model.dart';
import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final List<LeadItem> leads;
  final List<RecordatorioItem> recordatorios;
  final UserModel usuario;

  const HomeLoaded({required this.leads, required this.usuario, required this.recordatorios});

  @override
  List<Object?> get props => [leads];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
