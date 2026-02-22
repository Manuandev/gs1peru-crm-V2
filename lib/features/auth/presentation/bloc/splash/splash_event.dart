// lib/features/auth/presentation/bloc/splash/splash_event.dart
// ============================================================
// SPLASH - EVENTOS
// ============================================================

import 'package:equatable/equatable.dart';

abstract class SplashEvent extends Equatable {
  const SplashEvent();

  @override
  List<Object?> get props => [];
}

/// Inicia la verificación de sesión.
/// Se dispara automáticamente al crear el SplashBloc en SplashPage.
///
/// CUÁNDO: Al montar SplashPage
/// QUIÉN:  SplashPage → SplashBloc()..add(SplashCheckSessionRequested())
class SplashCheckSessionRequested extends SplashEvent {
  const SplashCheckSessionRequested();
}