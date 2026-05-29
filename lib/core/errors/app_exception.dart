class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Se lanza cuando se encuentra una sesión en base de datos local,
/// pero el usuario NO había marcado la opción de recordar sesión.
/// Usado para pasar los datos de vuelta al formulario de Login.
class SessionNotRememberedException implements Exception {
  final String username;
  final String password;
  const SessionNotRememberedException(this.username, this.password);
}