// lib/features/lead/domain/entities/lead_detail.dart

import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalle {
  final Lead lead;
  final List<ComentarioLead> comentarios;

  const LeadDetalle({required this.lead, required this.comentarios});
}
