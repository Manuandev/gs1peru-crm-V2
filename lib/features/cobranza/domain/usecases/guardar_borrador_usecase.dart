// lib/features/cobranza/domain/usecases/guardar_borrador_usecase.dart

import 'package:app_crm/core/network/crud_result.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class GuardarBorradorUseCase {
  final CobranzaRepository _repository;
  const GuardarBorradorUseCase(this._repository);

  Future<CrudResult> call(int idCobranza) =>
      _repository.guardarBorrador(idCobranza);
}
