// lib/features/lead/domain/usecases/obtener_negociaciones_contacto_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetNegociacionesLead {
  final LeadRepository _repository;

  GetNegociacionesLead(this._repository);

  Future<List<NegociacionLead>> call(int idLead) =>
      _repository.obtenerNegociaciones(idLead);
}
