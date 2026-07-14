// lib/features/solicitudes/domain/usecases/get_detalle_solicitud_usecase.dart

import 'package:app_crm/features/solicitudes/domain/entities/solicitud_detalle.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class GetDetalleSolicitudUseCase {
  final SolicitudRepository _repository;
  const GetDetalleSolicitudUseCase(this._repository);

  Future<SolicitudDetalle> call(String numSol) =>
      _repository.getDetalleSolicitud(numSol);
}
