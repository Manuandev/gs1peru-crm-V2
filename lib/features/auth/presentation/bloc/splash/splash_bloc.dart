// lib/features/auth/presentation/bloc/splash/splash_bloc.dart
// ============================================================
// SPLASH BLOC — CON REPOSITORIO REAL
// ============================================================

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';

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
    } on SessionNotRememberedException catch (e) {
      emit(SplashSessionNotFound(prefillUsername: e.username, prefillPassword: e.password));
    } on AppException catch (e) {
      emit(SplashSessionNotFound(message: e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(SplashError(message: e.toString()));
    }
  }
}
