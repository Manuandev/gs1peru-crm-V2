// lib/features/solicitudes/domain/usecases/eliminar_solicitud_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class EliminarSolicitudUseCase {
  final SolicitudRepository _repository;
  const EliminarSolicitudUseCase(this._repository);

  Future<CrudResult> call(String numSol) =>
      _repository.eliminarSolicitud(numSol);
}
