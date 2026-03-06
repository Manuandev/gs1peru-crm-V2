// lib/features/auth/presentation/bloc/login/login_bloc.dart
// ============================================================
// LOGIN BLOC — CONEXIÓN REAL CON DIO
// ============================================================

import 'dart:io';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase _loginUsecase;
  final AuthRepository _authRepository;

  LoginBloc({
    required LoginUsecase loginUsecase,required AuthRepository authRepository})
    :  _loginUsecase = loginUsecase,
        _authRepository = authRepository,
      super(const LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithGoogleSubmitted>(_onLoginWithGoogleSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    try {
       // ✅ Usa el usecase, no el repositorio directamente
      final user = await _loginUsecase(
        username: event.username,
        password: event.password,
        rememberSession: event.rememberSession,
      );

      emit(LoginSuccess(userId: user.userId, username: user.fullName));
    } on AppException catch (e) {
      // ❌ La API rechazó las credenciales
      emit(LoginFailure(e.message));
    } on SocketException {
      // ❌ Sin conexión a internet
      emit(
        const LoginFailure(
          'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
        ),
      );
    } catch (e, stackTrace) {
      // ❌ Error inesperado — queda registrado en BlocObserver
      addError(e, stackTrace);
      emit(LoginFailure('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoginWithGoogleSubmitted(
    LoginWithGoogleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    try {
      // v7: singleton + authenticate()
      // Solo funciona en Android/iOS — en esta app es mobile, ok
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        emit(
          const LoginFailure(
            'Google Sign-In no está disponible en este dispositivo',
          ),
        );
        return;
      }

      // Abre el selector de cuentas Google
      final googleUser = await GoogleSignIn.instance.authenticate();

      final user = await _authRepository.loginWithGoogle(
        email: googleUser.email,
      );

      emit(LoginSuccess(userId: user.userId, username: user.fullName));
    } on GoogleSignInException catch (e) {
      // Canceló la selección
      if (e.code == GoogleSignInExceptionCode.canceled) {
        emit(const LoginInitial());
        return;
      }
      emit(
        LoginFailure('Error de Google: ${e.description ?? e.code.toString()}'),
      );
    } on AppException catch (e) {
      emit(LoginFailure(e.message)); // ← posicional
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const LoginFailure('Error inesperado al iniciar con Google'));
    }
  }
}
