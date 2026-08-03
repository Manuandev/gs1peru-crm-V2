// lib/features/lead/domain/usecases/obtener_negociaciones_contacto_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

// 2026-08-03 — migrado de idNumero a idContacto, ver comentario en
// LeadRepository.obtenerNegociaciones.
class GetNegociacionesLead {
  final LeadRepository _repository;

  GetNegociacionesLead(this._repository);

  Future<List<Negociacion>> call(int idContacto) =>
      _repository.obtenerNegociaciones(idContacto);
}
