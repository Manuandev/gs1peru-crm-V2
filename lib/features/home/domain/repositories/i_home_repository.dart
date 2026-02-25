import 'package:app_crm/features/home/data/models/lead_model.dart';

abstract class IHomeRepository {
  Future<List<LeadItem>> listarLeads();
}
