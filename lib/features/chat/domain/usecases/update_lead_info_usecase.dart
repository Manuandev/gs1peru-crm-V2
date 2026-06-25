// lib/features/chat/domain/usecases/update_lead_info_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class UpdateLeadInfoUseCase {
  final LeadRepository repository;

  const UpdateLeadInfoUseCase(this.repository);

  Future<CrudResult> call(Lead leadModificado) async {
    return await repository.updateLeadCompleto(leadModificado);
  }
}
