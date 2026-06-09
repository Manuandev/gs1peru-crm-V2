// lib/features/cobranza/domain/usecases/get_cobranzas_usecase.dart

import 'package:app_crm/features/cobranza/index_cobranza.dart';

class GetDetalleCobranzaUseCase {
  final CobranzaRepository _repository;
  const GetDetalleCobranzaUseCase(this._repository);

  Future<CobranzaDetalle?> call(String id) => _repository.getDetalleCobranza(id);
}
