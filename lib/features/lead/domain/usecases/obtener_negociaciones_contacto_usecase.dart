// lib/features/lead/domain/usecases/obtener_negociaciones_contacto_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class ObtenerNegociacionesContactoUseCase {
  final LeadRepository _repository;

  ObtenerNegociacionesContactoUseCase(this._repository);

  Future<List<Lead>> call(int idContacto) =>
      _repository.obtenerNegociacionesDeContacto(idContacto);
}
