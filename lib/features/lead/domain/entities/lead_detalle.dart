// lib/features/lead/domain/entities/lead_detalle.dart

import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalle {
  final Lead lead;
  final List<ComentarioLead> comentarios;

  const LeadDetalle({required this.lead, required this.comentarios});
}
