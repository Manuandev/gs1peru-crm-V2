// lib/features/lead/data/models/lead_detail_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadDetalleModel extends LeadDetalle {
  const LeadDetalleModel({required super.lead, required super.comentarios});

  factory LeadDetalleModel.parse(String rawResponse) {
    final partes = rawResponse.split(AppConstants.sepListas);
    final leadRaw = partes.isNotEmpty ? partes[0] : '';
    final comentariosRaw = partes.length > 1 ? partes[1] : '';

    final lead = LeadModel.parse(leadRaw);

    final comentarios = comentariosRaw.trim().isEmpty
        ? <ComentarioLeadModel>[]
        : ComentarioLeadModel.parseList(comentariosRaw);

    return LeadDetalleModel(
      lead: lead!,
      comentarios: comentarios,
    );
  }
}
