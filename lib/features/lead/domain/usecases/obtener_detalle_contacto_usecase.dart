// lib/features/lead/domain/usecases/obtener_detalle_contacto_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class ObtenerDetalleContactoUseCase {
  final LeadRepository _repository;

  ObtenerDetalleContactoUseCase(this._repository);

  Future<ContactoDetalle> call(int idLead) =>
      _repository.obtenerDetalleContacto(idLead);
}
