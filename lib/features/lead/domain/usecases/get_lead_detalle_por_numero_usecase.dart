// lib\features\lead\domain\usecases\get_lead_detalle_por_numero_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetLeadDetallePorNumeroUseCase {
  final LeadRepository _repository;
  const GetLeadDetallePorNumeroUseCase(this._repository);

  Future<Negociacion> call(int idNumero) =>
      _repository.getLeadDetallePorNumero(idNumero);
}
