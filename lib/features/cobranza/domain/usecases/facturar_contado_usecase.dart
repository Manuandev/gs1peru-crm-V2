// lib/features/cobranza/domain/usecases/facturar_contado_usecase.dart

import 'package:app_crm/core/network/crud_result.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class FacturarContadoUseCase {
  final CobranzaRepository _repository;
  const FacturarContadoUseCase(this._repository);

  Future<CrudResult> call(int idCobranza) =>
      _repository.facturarContado(idCobranza);
}
