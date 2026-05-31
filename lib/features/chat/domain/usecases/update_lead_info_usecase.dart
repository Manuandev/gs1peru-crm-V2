// lib/features/chat/domain/usecases/update_lead_info_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class UpdateLeadInfoUseCase {
  final ChatRepository repository;

  const UpdateLeadInfoUseCase(this.repository);

  // Recibe la entidad completa con todos los datos modificados
  Future<CrudResult> call(InfoLead leadModificado) async {
    return await repository.updateLeadCompleto(leadModificado);
  }
}
