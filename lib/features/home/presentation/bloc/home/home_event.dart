// lib/features/home/presentation/bloc/home/home_event.dart
// ============================================================
// HOME - EVENTOS
// ============================================================

import 'package:app_crm/index_dependencies.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// La pantalla se inicializó.
/// Carga los datos del usuario (nombre, email, badges).
/// Disparado automáticamente por HomePage al crearse.
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Se pidió actualizar los datos del dashboard.
/// Disparado por: pull-to-refresh, botón reintentar (manual, [silencioso]
/// = false → sí emite HomeLoading) o recarga automática por notificación
/// del socket (silencioso = true → sin HomeLoading, se ve como una
/// actualización en tiempo real).
class HomeRefresh extends HomeEvent {
  final bool silencioso;
  const HomeRefresh({this.silencioso = false});

  @override
  List<Object?> get props => [silencioso];
}

/// Una prioridad se gestionó correctamente (botón "Gestionar").
/// Quita el registro de `state.prioridades` sin volver a pedir todo el Home.
class HomePrioridadGestionada extends HomeEvent {
  final int idNumero;
  const HomePrioridadGestionada(this.idNumero);

  @override
  List<Object?> get props => [idNumero];
}

// ── NOTA SOBRE LOGOUT ───────────────────────────────────────
// El logout NO se maneja aquí.
// El Drawer dispara: context.read<AuthBloc>().add(AuthLogoutRequested())
// AuthBloc limpia la sesión y emite AuthUnauthenticated
// AppWidget navega al Login automáticamente.
// El HomeBloc no sabe nada de sesión.
// ────────────────────────────────────────────────────────────
