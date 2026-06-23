// lib/features/auth/domain/usecases/login_con_google_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';

/// Caso de uso: Iniciar sesión con Google OAuth2.
class LoginConGoogleUsecase {
  final AuthRepository _repository;
  const LoginConGoogleUsecase(this._repository);

  Future<UserModel> call({
    required String accessToken,
    required String correo,
  }) => _repository.loginWithGoogle(
        accessToken: accessToken,
        correo: correo,
      );
}
