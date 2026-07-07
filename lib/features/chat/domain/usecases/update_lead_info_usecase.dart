// lib/features/chat/domain/usecases/update_lead_info_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class UpdateLeadInfoUseCase {
  final LeadRepository repository;

  const UpdateLeadInfoUseCase(this.repository);

  Future<CrudResult> call(Negociacion negociacion, int idNumero) async {
    return await repository.updateNegociacion(negociacion, idNumero);
  }
}
