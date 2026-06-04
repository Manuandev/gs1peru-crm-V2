// lib/features/cobranza/domain/usecases/get_cobranzas_usecase.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

class GetCobranzasUseCase {
  final CobranzaRepository _repository;
  const GetCobranzasUseCase(this._repository);

  Future<List<Cobranza>> call() => _repository.getCobranzas();
}
