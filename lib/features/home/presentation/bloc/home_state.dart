// lib/features/home/presentation/bloc/home_state.dart
// ============================================================
// HOME - ESTADOS
// ============================================================
//
// FLUJO:
// HomeInitial → HomeLoading → HomeLoaded
//                          └→ HomeError (botón reintentar)
// ============================================================

import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Recién creado, antes de cargar datos.
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Cargando datos del usuario desde BD o API.
/// La UI muestra un spinner.
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Datos cargados correctamente.
/// La UI muestra el contenido del Home con DrawerHeader y badges.
class HomeLoaded extends HomeState {
  /// Nombre del usuario para el DrawerHeader
  final String userName;

  /// Subtítulo del DrawerHeader (email, cargo, etc.)
  final String? userSubtitle;

  /// URL del avatar (null → usa ícono por defecto)
  final String? userAvatarUrl;

  /// Cantidad de chats sin leer
  final int unreadChats;

  /// Cantidad de recordatorios pendientes
  final int pendingRecordatorios;

  /// Cantidad de leads nuevos
  final int newLeads;

  const HomeLoaded({
    required this.userName,
    this.userSubtitle,
    this.userAvatarUrl,
    this.unreadChats = 0,
    this.pendingRecordatorios = 0,
    this.newLeads = 0,
  });

  /// ¿Hay algún badge activo para mostrar en el drawer?
  bool get hasBadges =>
      unreadChats > 0 || pendingRecordatorios > 0 || newLeads > 0;

  @override
  List<Object?> get props => [
        userName,
        userSubtitle,
        userAvatarUrl,
        unreadChats,
        pendingRecordatorios,
        newLeads,
      ];
}

/// Error al cargar datos.
/// La UI muestra un botón "Reintentar" que dispara HomeRefreshRequested.
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}