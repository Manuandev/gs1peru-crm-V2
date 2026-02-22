// lib/features/auth/presentation/bloc/splash/splash_bloc.dart
// ============================================================
// SPLASH BLOC — CON REPOSITORIO REAL
// ============================================================

import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final IAuthRepository _authRepository;

  SplashBloc({required IAuthRepository authRepository})
    : _authRepository = authRepository,
      super(const SplashInitial()) {
    on<SplashCheckSessionRequested>(_onCheckSessionRequested);
  }

  Future<void> _onCheckSessionRequested(
    SplashCheckSessionRequested event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    try {
      // tryRestoreSession hace todo:
      // 1. Revisa si hay credenciales en SQLite
      // 2. Verifica si expiraron
      // 3. Re-login a la API automáticamente
      // 4. Llena _currentUser en memoria
      // Retorna null si no hay sesión o expiró
      final user = await _authRepository.tryRestoreSession();

      if (user == null) {
        emit(const SplashSessionNotFound());
        return;
      }

      emit(SplashSessionFound(userId: user.userId, username: user.fullName));
    } on SocketException {
      // Sin internet → usa la sesión local guardada
      // final local = await _authRepository.getStoredSession();
      // if (local != null && local.userId.isNotEmpty) {
      //   emit(
      //     SplashSessionFound(userId: local.userId, username: local.fullName),
      //   );
      // } else {
      //   emit(const SplashSessionNotFound());
      // }
      emit(
        const SplashSessionNotFound(
          message:
              'Sin conexión a internet. Por favor inicia sesión nuevamente.',
        ),
      );
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const SplashSessionNotFound());
    }
  }
}
