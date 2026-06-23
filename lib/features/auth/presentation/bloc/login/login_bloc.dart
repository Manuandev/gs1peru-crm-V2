// lib/features/auth/presentation/bloc/login/login_bloc.dart
// ============================================================
// LOGIN BLOC — CONEXIÓN REAL CON DIO
// ============================================================

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
    emit(const LoginLoading());

    try {
      if (!GoogleSignIn.instance.supportsAuthenticate()) {
        emit(
          const LoginFailure(
            'Google Sign-In no está disponible en este dispositivo',
          ),
        );
        return;
      }

      // Abre el selector nativo de cuentas Google
      final cuenta = await GoogleSignIn.instance.authenticate();

      // idToken no requiere serverClientId — viene incluido en authenticate().
      // El backend valida con Google tokeninfo usando este token.
      final idToken = cuenta.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        emit(const LoginFailure('No se pudo obtener el token de Google'));
        return;
      }

      final usuario = await _loginConGoogleUsecase(
        accessToken: idToken,
        correo: cuenta.email,
      );

      emit(LoginSuccess(userId: usuario.userId, username: usuario.fullName));
    } on GoogleSignInException catch (e) {
      // Usuario canceló el selector → no mostrar nada, volver al estado inicial
      if (e.code == GoogleSignInExceptionCode.canceled) {
        emit(const LoginInitial());
        return;
      }
      emit(
        LoginFailure('Error de Google: ${e.description ?? e.code.toString()}'),
      );
    } on AppException catch (e) {
      emit(LoginFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const LoginFailure('Error inesperado al iniciar con Google'));
    }
  }
}
