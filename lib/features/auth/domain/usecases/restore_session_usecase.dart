// lib/features/auth/domain/usecases/restore_session_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso: Restaurar sesión guardada (usado en el Splash).
class RestoreSessionUsecase {
  final AuthRepository _repository;
  const RestoreSessionUsecase(this._repository);

  Future<UserModel?> call() => _repository.tryRestoreSession();
}