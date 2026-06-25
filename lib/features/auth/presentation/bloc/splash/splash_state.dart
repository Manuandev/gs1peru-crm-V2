// lib/features/auth/presentation/bloc/splash/splash_state.dart
// ============================================================
// SPLASH - ESTADOS
// ============================================================
//
// FLUJO:
// SplashInitial → SplashLoading → SplashMostrarOnboarding  (primer ingreso)
//                              └→ SplashSessionFound        (recurrente con sesión)
//                              └→ SplashSessionNotFound     (recurrente sin sesión)
//                              └→ SplashError
//
// QUÉ HACE LA VIEW CON CADA ESTADO:
// - SplashLoading           → primera slide estática (pantalla de carga)
// - SplashMostrarOnboarding → carrusel completo e interactivo
// - SplashSessionFound      → listener dispara AuthSessionRestored → Home
// - SplashSessionNotFound   → listener navega a Login
// - SplashError             → listener navega a Login
// ============================================================

import 'package:app_crm/index_dependencies.dart';

abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => [];
}

/// Recién montado, antes de empezar la verificación.
class SplashInitial extends SplashState {
  const SplashInitial();
}

/// Consultando SQLite y el backend.
/// La View muestra la primera slide del carrusel de forma estática (sin botones).
class SplashLoading extends SplashState {
  const SplashLoading();
}

/// El usuario nunca completó el onboarding (onboarding_completado == null).
/// La View muestra el carrusel completo e interactivo.
/// Al finalizar → setSetting('onboarding_completado', 'true') → goToLogin()
class SplashMostrarOnboarding extends SplashState {
  const SplashMostrarOnboarding();
}

/// Se encontró una sesión válida en el almacenamiento local.
/// La View notificará al AuthBloc para ir al Home.
class SplashSessionFound extends SplashState {
  final String userId;
  final String username;

  const SplashSessionFound({required this.userId, required this.username});

  @override
  List<Object?> get props => [userId, username];
}

/// No hay sesión guardada o fue limpiada.
/// La View notificará al AuthBloc para ir al Login.
class SplashSessionNotFound extends SplashState {
  final String? message; // ← mensaje opcional
  final String? prefillUsername;
  final String? prefillPassword;
  const SplashSessionNotFound({this.message, this.prefillUsername, this.prefillPassword});
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
