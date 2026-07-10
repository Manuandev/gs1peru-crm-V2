// lib/features/solicitudes/domain/usecases/guardar_archivo_solicitud_usecase.dart

import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class GuardarArchivoSolicitudUseCase {
  final SolicitudRepository _repository;
  const GuardarArchivoSolicitudUseCase(this._repository);

  Future<bool> call({
    required String numSol,
    required String tipo,
    required String fileName,
    required String fileExt,
    required List<int> fileBytes,
  }) => _repository.guardarArchivo(
    numSol: numSol,
    tipo: tipo,
    fileName: fileName,
    fileExt: fileExt,
    fileBytes: fileBytes,
  );
}
