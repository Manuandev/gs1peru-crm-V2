// lib/features/auth/domain/usecases/recuperar_clave_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class RecuperarClaveUseCase {
  final AuthRepository _repository;

  const RecuperarClaveUseCase(this._repository);

  Future<CrudResult> call(String correo) => _repository.recuperarClave(correo);
}
