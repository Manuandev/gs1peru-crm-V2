// lib\features\lead\domain\usecases\get_leads_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetLeadsUseCase {
  final LeadRepository repository;
  const GetLeadsUseCase(this.repository);

  Future<List<Lead>> call() => repository.getLeads();
}
