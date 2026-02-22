// lib/features/auth/presentation/bloc/login/login_bloc.dart
// ============================================================
// LOGIN BLOC — CONEXIÓN REAL CON DIO
// ============================================================

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IAuthRepository _authRepository;

  LoginBloc({required IAuthRepository authRepository})
    : _authRepository = authRepository,
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
      // ── LLAMADA REAL ────────────────────────────────────
      // 1. AuthRepository.login() → llama a la API con Dio
      // 2. Si ok → guarda en SharedPreferences automáticamente
      // 3. Retorna SessionEntity
      final session = await _authRepository.login(
        username: event.username,
        password: event.password,
        rememberSession: event.rememberSession,
      );

      emit(LoginSuccess(userId: session.userId, username: session.fullName));
    } on AuthException catch (e) {
      // ❌ La API rechazó las credenciales
      emit(LoginFailure(e.message));
    } on SocketException {
      // ❌ Sin conexión a internet
      emit(
        const LoginFailure(
          'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
        ),
      );
    } on NetworkException catch (e) {
      // ❌ Timeout o error HTTP
      emit(LoginFailure(e.message));
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
    } on AuthException catch (e) {
      emit(LoginFailure(e.message)); // ← posicional
    } on NetworkException catch (e) {
      emit(LoginFailure(e.message)); // ← posicional
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const LoginFailure('Error inesperado al iniciar con Google'));
    }
  }
}
