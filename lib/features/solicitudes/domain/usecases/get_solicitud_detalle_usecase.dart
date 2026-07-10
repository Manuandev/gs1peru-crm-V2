// lib/features/solicitudes/domain/usecases/get_solicitud_detalle_usecase.dart

import 'package:app_crm/features/solicitudes/data/models/solicitud_detalle_model.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class GetSolicitudDetalleUseCase {
  final SolicitudRepository _repository;
  const GetSolicitudDetalleUseCase(this._repository);

  Future<SolicitudDetalleModel> call(String numSol) =>
      _repository.getSolicitudDetalle(numSol);
}
