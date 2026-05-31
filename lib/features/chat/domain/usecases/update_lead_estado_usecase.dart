// lib/features/chat/domain/usecases/update_lead_estado_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class UpdateLeadEstadoUseCase {
  final ChatRepository repository;

  const UpdateLeadEstadoUseCase(this.repository);

  Future<CrudResult> call(int idLead, String idEstado) async {
    return await repository.updateEstado(idLead, idEstado);
  }
}
