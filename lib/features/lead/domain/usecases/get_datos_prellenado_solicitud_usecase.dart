// lib/features/lead/domain/usecases/get_datos_prellenado_solicitud_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetDatosPrellenadoSolicitudUseCase {
  final LeadRepository _repository;
  const GetDatosPrellenadoSolicitudUseCase(this._repository);

  Future<DatosPrellenadoSolicitud> call(int idLead) =>
      _repository.getDatosPrellenadoSolicitud(idLead);
}
