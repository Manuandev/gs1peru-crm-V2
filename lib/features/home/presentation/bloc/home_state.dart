// lib/features/home/presentation/bloc/home_state.dart
// ============================================================
// HOME - ESTADOS
// ============================================================
//
// FLUJO:
// HomeInitial → HomeLoading → HomeLoaded
//                          └→ HomeError (botón reintentar)
// ============================================================

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

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
  final Home home;
  final UserModel usuario;

  const HomeLoaded({required this.home, required this.usuario});

  // Atajos para acceso rápido
  int get totConversaciones => home.totConversaciones;
  int get totProspectos => home.totProspectos;
  int get totPropuestas => home.totPropuestas;
  int get totCobranza => home.totCobranza;
  List<Prioridad> get prioridades => home.prioridades;

  @override
  List<Object?> get props => [home, usuario];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
