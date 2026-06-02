// lib\features\lead\domain\repositories\lead_repository.dart

import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadRepository {
  Future<List<LeadEntity>> getProspectos();

  Future<List<LeadEntity>> getPropuestas();
}
