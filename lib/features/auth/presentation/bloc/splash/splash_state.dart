// lib/features/auth/presentation/bloc/splash/splash_state.dart
// ============================================================
// SPLASH - ESTADOS
// ============================================================
//
// FLUJO:
// SplashInitial → SplashLoading → SplashSessionFound
//                              └→ SplashSessionNotFound
//                              └→ SplashError
//
// QUÉ HACE LA VIEW CON CADA ESTADO:
// - SplashLoading         → muestra animación (esperando el timer mínimo)
// - SplashSessionFound    → notifica AuthBloc con AuthSessionRestored
// - SplashSessionNotFound → notifica AuthBloc con AuthSessionEmpty
// - SplashError           → notifica AuthBloc con AuthSessionEmpty (va al Login)
// ============================================================

import 'package:equatable/equatable.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Recién montado, antes de empezar la verificación.
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Consultando el repositorio local.
/// La View muestra la animación del splash en este estado.
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// Se encontró una sesión válida en el almacenamiento local.
/// La View notificará al AuthBloc para ir al Home.
class SplashSessionFound extends SplashState {
  final String userId;
  final String username;

  const SplashSessionFound({
    required this.userId,
    required this.username,
  });

  @override
  List<Object?> get props => [userId, username];
}

/// No hay sesión guardada o fue limpiada.
/// La View notificará al AuthBloc para ir al Login.
class SplashSessionNotFound extends SplashState {
  final String? message; // ← mensaje opcional
  const SplashSessionNotFound({this.message});
}

/// Error inesperado durante la verificación.
/// Se trata como SplashSessionNotFound por seguridad.
/// El error queda registrado en BlocObserver para debugging.
class SplashError extends SplashState {
  final String message;

  const SplashError({required this.message});

  @override
  List<Object?> get props => [message];
}