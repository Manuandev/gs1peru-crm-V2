// lib/features/cobranza/domain/usecases/guardar_plan_credito_usecase.dart

import 'package:app_crm/core/network/crud_result.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class GuardarPlanCreditoUseCase {
  final CobranzaRepository _repository;
  const GuardarPlanCreditoUseCase(this._repository);

  Future<CrudResult> call(int idCobranza, List<CuotaPlan> cuotas) =>
      _repository.guardarPlanCredito(idCobranza, cuotas);
}
