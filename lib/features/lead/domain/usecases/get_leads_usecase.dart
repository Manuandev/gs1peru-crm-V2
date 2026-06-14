// lib/features/lead/domain/usecases/get_leads_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetLeadsUseCase {
  final LeadRepository _repository;
  const GetLeadsUseCase(this._repository);

  Future<List<Lead>> call(String proceso) => _repository.getLeads(proceso);
}
