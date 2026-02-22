// lib/features/auth/presentation/bloc/login/login_event.dart
// ============================================================
// LOGIN - EVENTOS
// ============================================================

import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// El usuario presionó "Iniciar Sesión" con sus credenciales.
/// Disparado por: LoginView._handleLogin()
///
/// FLUJO:
/// LoginSubmitted → LoginBloc._onLoginSubmitted()
///   → LoginLoading (spinner en botón)
///   → valida con API o SQLite
///   → LoginSuccess → LoginView notifica al AuthBloc → Home
///   → LoginFailure → LoginView muestra snackbar de error
class LoginSubmitted extends LoginEvent {
  final String username;
  final String password;
  final bool rememberSession;

  const LoginSubmitted({
    required this.username,
    required this.password,
    this.rememberSession = false,
  });
 
  @override
  List<Object?> get props => [username, password];
}


class LoginWithGoogleSubmitted extends LoginEvent {
  const LoginWithGoogleSubmitted();
}