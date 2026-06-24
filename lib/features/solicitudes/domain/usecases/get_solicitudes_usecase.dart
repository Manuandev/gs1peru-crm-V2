// lib/features/solicitudes/domain/usecases/get_solicitudes_usecase.dart

import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class GetSolicitudesUseCase {
  final SolicitudRepository _repository;
  const GetSolicitudesUseCase(this._repository);

  Future<List<Solicitud>> call() => _repository.getSolicitudes();
}
