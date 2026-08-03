// lib\features\lead\domain\usecases\get_lead_detalle_por_numero_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

// 2026-08-03 — migrado de idNumero a idContacto, ver comentario en
// LeadRepository.getLeadDetallePorContacto.
class GetLeadDetallePorContactoUseCase {
  final LeadRepository _repository;
  const GetLeadDetallePorContactoUseCase(this._repository);

  Future<Negociacion> call(int idContacto) =>
      _repository.getLeadDetallePorContacto(idContacto);
}
