// lib/features/auth/presentation/bloc/splash/splash_bloc.dart
// ============================================================
// SPLASH BLOC — CON REPOSITORIO REAL
// ============================================================

import 'dart:io';

import 'package:app_crm/features/auth/index_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final RestoreSessionUsecase _restoreSessionUsecase;

  SplashBloc({required RestoreSessionUsecase restoreSessionUsecase})
    : _restoreSessionUsecase = restoreSessionUsecase,
      super(const SplashInitial()) {
    on<SplashCheckSessionRequested>(_onCheckSessionRequested);
  }

  Future<void> _onCheckSessionRequested(
    SplashCheckSessionRequested event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    try {
      // ✅ Usa el usecase, no el repositorio directamente
      final user = await _restoreSessionUsecase();

      if (user == null) {
        emit(const SplashSessionNotFound());
        return;
      }

      emit(SplashSessionFound(userId: user.userId, username: user.fullName));
    } on SocketException {
      emit(
        const SplashSessionNotFound(
          message:
              'Sin conexión a internet. Por favor inicia sesión nuevamente.',
        ),
      );
    } catch (e, stackTrace) {
      // ✅ FIX: ahora usa SplashError correctamente en vez de SplashSessionNotFound
      addError(e, stackTrace);
      emit(SplashError(message: e.toString()));
    }
  }
}
