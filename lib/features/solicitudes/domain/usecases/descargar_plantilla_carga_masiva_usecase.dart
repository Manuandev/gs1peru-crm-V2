// lib/features/solicitudes/domain/usecases/descargar_plantilla_carga_masiva_usecase.dart

import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class DescargarPlantillaCargaMasivaUseCase {
  final SolicitudRepository _repository;
  const DescargarPlantillaCargaMasivaUseCase(this._repository);

  Future<List<int>> call() => _repository.descargarPlantillaCargaMasiva();
}
