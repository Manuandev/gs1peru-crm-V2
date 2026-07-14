// lib/features/cobranza/domain/usecases/guardar_plan_credito_usecase.dart

import 'package:app_crm/core/network/crud_result.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class GuardarPlanCreditoUseCase {
  final CobranzaRepository _repository;
  const GuardarPlanCreditoUseCase(this._repository);

  Future<CrudResult> call({
    required String numSol,
    required String moneda,
    required List<CuotaPlan> cuotas,
  }) => _repository.guardarPlanCredito(numSol: numSol, moneda: moneda, cuotas: cuotas);
}
