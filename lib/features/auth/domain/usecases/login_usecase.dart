// lib/features/auth/domain/usecases/login_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: Iniciar sesión con credenciales.
class LoginUsecase {
  final AuthRepository _repository;
  const LoginUsecase(this._repository);

  Future<UserModel> call({
    required String username,
    required String password,
    bool rememberSession = false,
  }) => _repository.login(
        username: username,
        password: password,
        rememberSession: rememberSession,
      );
}