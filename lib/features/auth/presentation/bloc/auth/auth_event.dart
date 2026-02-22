// lib/features/auth/presentation/bloc/auth/auth_event.dart
// ============================================================
// AUTH - EVENTOS
// ============================================================
//
// EVENTOS DISPONIBLES:
//
// ┌─────────────────────────────────────────────────────────┐
// │  QUIÉN LO DISPARA       EVENTO              RESULTADO   │
// ├─────────────────────────────────────────────────────────┤
// │  SplashView (sesión ok) AuthSessionRestored → Home      │
// │  SplashView (sin sesión)AuthSessionEmpty    → Login     │
// │  LoginView (login ok)   AuthLoginSuccess    → Home      │
// │  Drawer (logout)        AuthLogoutRequested → Login     │
// └─────────────────────────────────────────────────────────┘
//
// REGLA:
// Ningún otro Bloc despacha estos eventos.
// Solo las VIEWS los disparan al AuthBloc.
// ============================================================

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// ── EVENTOS DEL SPLASH ──────────────────────────────────────

/// El Splash encontró una sesión guardada y válida.
/// Disparado por: SplashView cuando SplashBloc emite SplashSessionFound.
class AuthSessionRestored extends AuthEvent {
  final String userId;
  final String username;

  const AuthSessionRestored({
    required this.userId,
    required this.username,
  });

  @override
  List<Object?> get props => [userId, username];
}

/// El Splash NO encontró sesión o hubo un error.
/// Disparado por: SplashView cuando SplashBloc emite SplashSessionNotFound o SplashError.
class AuthSessionEmpty extends AuthEvent {
  const AuthSessionEmpty();
}

// ── EVENTOS DEL LOGIN ────────────────────────────────────────

/// Login exitoso con credenciales válidas.
/// Disparado por: LoginView cuando LoginBloc emite LoginSuccess.
class AuthLoginSuccess extends AuthEvent {
  final String userId;
  final String username;

  const AuthLoginSuccess({
    required this.userId,
    required this.username,
  });

  @override
  List<Object?> get props => [userId, username];
}

// ── EVENTOS DEL DRAWER ───────────────────────────────────────

/// El usuario solicitó cerrar sesión desde el Drawer.
/// Disparado por: AppDrawerWidget (botón "Cerrar Sesión").
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}