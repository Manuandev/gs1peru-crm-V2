// lib/features/chat/domain/usecases/get_plantilla_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class GetPlantillaUseCase {
  final ChatRepository repository;

  const GetPlantillaUseCase(this.repository);

  Future<Plantilla> call(int idPlantilla) async {
    return await repository.getPlantilla(idPlantilla);
  }
}
