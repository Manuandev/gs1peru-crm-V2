// lib/features/auth/presentation/bloc/login/login_bloc.dart
// ============================================================
// LOGIN BLOC — CONEXIÓN REAL CON DIO
// ============================================================

import 'package:flutter/foundation.dart';

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase _loginUsecase;
  final LoginConGoogleUsecase _loginConGoogleUsecase;

  LoginBloc({
    required LoginUsecase loginUsecase,
    required LoginConGoogleUsecase loginConGoogleUsecase,
  }) : _loginUsecase = loginUsecase,
       _loginConGoogleUsecase = loginConGoogleUsecase,
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
      final usuario = await _loginUsecase(
        username: event.username,
        password: event.password,
        rememberSession: event.rememberSession,
      );

      emit(LoginSuccess(userId: usuario.userId, username: usuario.fullName));
    } on AppException catch (e) {
      emit(LoginFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(LoginFailure('Error inesperado: ${e.toString()}'));
    }
  }

  Future<void> _onLoginWithGoogleSubmitted(
    LoginWithGoogleSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (kDebugMode) debugPrint('[GoogleSignIn] evento recibido, iniciando flujo');
    emit(const LoginLoading());

    try {
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        if (kDebugMode) debugPrint('[GoogleSignIn] supportsAuthenticate() = false');
        emit(
          const LoginFailure(
            'Google Sign-In no está disponible en este dispositivo',
          ),
        );
        return;
      }

      // Olvida cualquier cuenta cacheada por el SDK ANTES de abrir el
      // selector — si ya había una sesión ligera activa (ej. Manuel) y el
      // usuario elige una cuenta distinta, el SDK puede chocar con ese
      // estado cacheado y reportar todo el intento como "cancelado" (sin
      // aviso, sin llegar nunca a loginWithGoogle()) aunque sí se haya
      // elegido una cuenta — bug real reportado 2026-08-26, ver
      // auth/CLAUDE.md → "Cambio de cuenta Google...". Sin costo si es el
      // primer login (no hay nada que olvidar).
      await GoogleSignIn.instance.signOut();

      if (kDebugMode) debugPrint('[GoogleSignIn] abriendo selector nativo...');
      // Abre el selector nativo de cuentas Google
      final cuenta = await GoogleSignIn.instance.authenticate();
      if (kDebugMode) debugPrint('[GoogleSignIn] cuenta seleccionada: ${cuenta.email}');

      // idToken no requiere serverClientId — viene incluido en authenticate().
      // El backend valida con Google tokeninfo usando este token.
      final idToken = cuenta.authentication.idToken;
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] idToken presente=${idToken != null && idToken.isNotEmpty}');
      }

      if (idToken == null || idToken.isEmpty) {
        emit(const LoginFailure('No se pudo obtener el token de Google'));
        return;
      }

      if (kDebugMode) debugPrint('[GoogleSignIn] llamando al backend...');
      final usuario = await _loginConGoogleUsecase(
        accessToken: idToken,
        correo: cuenta.email,
      );
      if (kDebugMode) debugPrint('[GoogleSignIn] backend OK, userId=${usuario.userId}');

      emit(LoginSuccess(userId: usuario.userId, username: usuario.fullName));
    } on GoogleSignInException catch (e) {
      if (kDebugMode) {
        debugPrint('[GoogleSignIn] GoogleSignInException code=${e.code} description=${e.description}');
      }
      // Usuario canceló el selector → no mostrar nada, volver al estado inicial
      if (e.code == GoogleSignInExceptionCode.canceled) {
        emit(const LoginInitial());
        return;
      }
      emit(
        LoginFailure('Error de Google: ${e.description ?? e.code.toString()}'),
      );
    } on AppException catch (e) {
      if (kDebugMode) debugPrint('[GoogleSignIn] AppException: ${e.message}');
      emit(LoginFailure(e.message));
    } catch (e, stackTrace) {
      if (kDebugMode) debugPrint('[GoogleSignIn] Error genérico: $e');
      addError(e, stackTrace);
      emit(const LoginFailure('Error inesperado al iniciar con Google'));
    }
  }
}
