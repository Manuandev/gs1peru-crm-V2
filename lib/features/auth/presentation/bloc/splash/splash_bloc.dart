// lib/features/auth/presentation/bloc/splash/splash_bloc.dart
// ============================================================
// SPLASH BLOC
// ============================================================
//
// SECUENCIA DE ARRANQUE:
// 1. emit SplashLoading
// 2. Leer onboarding_completado de SQLite
//
// 3a. Si null (primer ingreso):
//     - emit SplashMostrarOnboarding  ← carrusel aparece inmediatamente
//     - ObtenerConfiguracionUseCase() en fire-and-forget (no bloquea)
//
// 3b. Si 'true' (usuario recurrente):
//     - await ObtenerConfiguracionUseCase() → ConfiguracionService().guardar()
//     - await RestoreSessionUsecase()
//       ├── user != null → emit SplashSessionFound
//       └── user == null → emit SplashSessionNotFound
// ============================================================

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final RestoreSessionUsecase _restoreSessionUsecase;
  final ObtenerConfiguracionUseCase _obtenerConfiguracionUseCase;

  SplashBloc({
    required RestoreSessionUsecase restoreSessionUsecase,
    required ObtenerConfiguracionUseCase obtenerConfiguracionUseCase,
  })  : _restoreSessionUsecase = restoreSessionUsecase,
        _obtenerConfiguracionUseCase = obtenerConfiguracionUseCase,
        super(const SplashInitial()) {
    on<SplashCheckSessionRequested>(_onCheckSessionRequested);
  }

  Future<void> _onCheckSessionRequested(
    SplashCheckSessionRequested event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    try {
      final onboarding = await LocalDatabase().getSetting('onboarding_completado');

      if (onboarding == null) {
        // Escenario 1 — primer ingreso: carrusel inmediato, config en background
        emit(const SplashMostrarOnboarding());
        unawaited(_cargarConfiguracion());
        return;
      }

      // Escenarios 2/3 — usuario recurrente: config bloqueante, luego sesión
      await _cargarConfiguracion();

      final user = await _restoreSessionUsecase();

      if (user == null) {
        emit(const SplashSessionNotFound());
        return;
      }

      emit(SplashSessionFound(userId: user.userId, username: user.fullName));
    } on SessionNotRememberedException catch (e) {
      emit(
        SplashSessionNotFound(
          prefillUsername: e.username,
          prefillPassword: e.password,
        ),
      );
    } on AppException catch (e) {
      emit(SplashSessionNotFound(message: e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(SplashError(message: e.toString()));
    }
  }

  /// Carga la configuración global y la persiste en [ConfiguracionService].
  /// Si falla, loguea el error y continúa sin bloquear al usuario.
  Future<void> _cargarConfiguracion() async {
    try {
      final config = await _obtenerConfiguracionUseCase();
      ConfiguracionService().guardar(config);
    } catch (e) {
      debugPrint('[SplashBloc] Error al cargar configuración: $e');
    }
  }
}
