// lib/features/chat/domain/usecases/subir_archivo_plantilla_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class SubirArchivoPlantillaUseCase {
  final ChatRepository repository;

  const SubirArchivoPlantillaUseCase(this.repository);

  Future<({String ruta, String nombre, String ext})?> call({
    required String filePath,
    required String fileName,
    required String tipo,
  }) => repository.subirArchivoPlantilla(
    filePath: filePath,
    fileName: fileName,
    tipo: tipo,
  );
}
