// lib/features/auth/presentation/bloc/login/login_state.dart
// ============================================================
// LOGIN - ESTADOS
// ============================================================
//
// FLUJO:
// LoginInitial → LoginLoading → LoginSuccess  → LoginView notifica AuthBloc
//                            └→ LoginFailure  → LoginView muestra error
// ============================================================

import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Formulario listo para ingresar datos.
/// Estado inicial y estado de "reset" tras un error.
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// Validando credenciales (mostrando spinner en el botón).
class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Credenciales válidas y sesión guardada correctamente.
/// La LoginView notificará al AuthBloc con AuthLoginSuccess.
class LoginSuccess extends LoginState {
  final String userId;
  final String username;

  const LoginSuccess({required this.userId, required this.username});

  @override
  List<Object?> get props => [userId, username];
}

/// Credenciales incorrectas o error de conexión.
/// La LoginView mostrará un snackbar con el mensaje.
class LoginFailure extends LoginState {
  final String message;

  const LoginFailure(this.message);

  // @override
  // List<Object?> get props => [message];
}
