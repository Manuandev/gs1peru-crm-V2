// lib\features\lead\domain\usecases\get_lead_detalle_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetLeadDetalleUseCase {
  final LeadRepository _repository;
  const GetLeadDetalleUseCase(this._repository);

  Future<Negociacion> call(int idLead) => _repository.getLeadDetalle(idLead);
}
