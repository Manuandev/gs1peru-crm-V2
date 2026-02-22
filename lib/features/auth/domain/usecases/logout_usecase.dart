// lib/features/auth/domain/usecases/logout_usecase.dart

import '../repositories/i_auth_repository.dart';

/// Caso de uso: Cerrar sesión.
///
/// RESPONSABILIDAD ÚNICA:
/// Llamar al repositorio para limpiar la sesión guardada.
///
/// ============================================================
/// AQUÍ VA TU LÓGICA DE LOGOUT
/// ============================================================
/// El repositorio se encargará de:
/// - Limpiar SQLite / SharedPreferences / Hive
/// - Invalidar el token con la API (si aplica)
/// ============================================================
class LogoutUsecase {
  final IAuthRepository _repository;

  const LogoutUsecase(this._repository);

  /// Ejecuta el logout.
  /// Se llama como función: await _logoutUsecase()
  Future<void> call() async {
    await _repository.logout();
  }
}