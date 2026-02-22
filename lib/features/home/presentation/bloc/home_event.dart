// lib/features/home/presentation/bloc/home_event.dart
// ============================================================
// HOME - EVENTOS
// ============================================================

import 'package:equatable/equatable.dart';

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

/// El usuario pidió actualizar los datos.
/// Disparado por: popup "Actualizar" o pull-to-refresh.
/// No muestra spinner completo para no parpadear la UI.
class HomeRefreshRequested extends HomeEvent {
  const HomeRefreshRequested();
}

// ── NOTA SOBRE LOGOUT ───────────────────────────────────────
// El logout NO se maneja aquí.
// El Drawer dispara: context.read<AuthBloc>().add(AuthLogoutRequested())
// AuthBloc limpia la sesión y emite AuthUnauthenticated
// AppWidget navega al Login automáticamente.
// El HomeBloc no sabe nada de sesión.
// ────────────────────────────────────────────────────────────