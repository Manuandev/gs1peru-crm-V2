// lib/features/auth/domain/repositories/i_auth_repository.dart

import 'package:app_crm/core/database/models/user_model.dart';

abstract class IHomeRepository {
  /// Usuario activo en memoria. Null si no hay sesión.
  UserModel? get currentUser;

  /// Login. Siempre llena memoria. SQLite solo si rememberSession=true.
  Future<UserModel> login({
    required String username,
    required String password,
    bool rememberSession = false,
  });

  Future<UserModel> loginWithGoogle({required String email});

  /// Splash: intenta re-login automático con credenciales guardadas en SQLite.
  Future<UserModel?> tryRestoreSession();

  /// Limpia memoria y SQLite.
  Future<void> logout();
}
