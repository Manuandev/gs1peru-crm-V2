// lib/features/auth/presentation/bloc/auth/auth_state.dart
// ============================================================
// AUTH - ESTADOS
// ============================================================
//
// FLUJO DE ESTADOS:
//
//   App inicia
//       │
//       ▼
//   AuthInitial ──── Splash verifica sesión
//       │
//       ├── sesión ok  ──► AuthAuthenticated ──► Router → /home
//       │
//       └── sin sesión ──► AuthUnauthenticated ──► Router → /login
//
//   Login ok ──────────► AuthAuthenticated ──► Router → /home
//
//   Logout ────────────► AuthLoading ──► AuthUnauthenticated ──► Router → /login
//
// ============================================================

import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial cuando la app arranca.
/// Dura mientras el SplashBloc verifica la sesión.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Procesando una operación de auth (logout en progreso).
/// La UI puede mostrar un loading global si lo necesita.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Hay una sesión activa y válida.
/// El AppWidget navega automáticamente a /home cuando detecta este estado.
///
/// DATOS DISPONIBLES:
/// Estos datos pueden ser leídos desde cualquier parte de la app con:
// ignore: unintended_html_in_doc_comment
/// context.read<AuthBloc>().state as AuthAuthenticated
class AuthAuthenticated extends AuthState {
  final String userId;
  final String username;

  const AuthAuthenticated({
    required this.userId,
    required this.username,
  });

  @override
  List<Object?> get props => [userId, username];
}

/// No hay sesión activa.
/// El AppWidget navega automáticamente a /login cuando detecta este estado.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}