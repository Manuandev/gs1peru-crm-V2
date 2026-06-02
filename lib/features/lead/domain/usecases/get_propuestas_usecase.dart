// lib\features\lead\domain\usecases\get_propuestas_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetPropuestasUseCase {
  final LeadRepository _repository;
  const GetPropuestasUseCase(this._repository);

  Future<List<LeadEntity>> call() => _repository.getPropuestas();
}
