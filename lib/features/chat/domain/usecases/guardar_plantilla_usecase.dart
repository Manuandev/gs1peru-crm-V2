// lib/features/chat/domain/usecases/guardar_plantilla_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class GuardarPlantillaUseCase {
  final ChatRepository repository;

  const GuardarPlantillaUseCase(this.repository);

  Future<CrudResult> call(Plantilla plantilla) async {
    return await repository.guardarPlantilla(plantilla);
  }
}
