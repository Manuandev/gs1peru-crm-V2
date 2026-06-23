// lib/features/auth/domain/entities/modo_autenticacion.dart

/// Modo de autenticación disponible en la pantalla de login.
///
/// TODO(backend): este valor vendrá del SP de configuración general
/// que se trae en SplashBloc al iniciar la app. Por ahora se
/// hardcodea en LoginView para desarrollo.
enum ModoAutenticacion {
  /// Solo botón "Ingresar con Google" — oculta campos de credenciales.
  soloGoogle,

  /// Solo campos usuario/clave + botón "Ingresar" — oculta botón Google.
  soloCredenciales,

  /// Muestra ambas opciones: Google + divisor + campos de credenciales.
  ambos,
}
