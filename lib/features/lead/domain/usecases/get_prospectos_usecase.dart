// lib\features\lead\domain\usecases\get_prospectos_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetProspectosUseCase {
  final LeadRepository _repository;
  const GetProspectosUseCase(this._repository);

  Future<List<LeadEntity>> call() => _repository.getProspectos();
}
