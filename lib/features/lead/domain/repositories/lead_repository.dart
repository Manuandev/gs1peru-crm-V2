// lib/features/lead/domain/repositories/lead_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadRepository {
  Future<List<Lead>> getLeads();
  Future<LeadDetalle> getLeadDetalle(int idLead);
  Future<void> toggleFavorito(int idLead, bool isFavorito);
  Future<CrudResult> updateLeadCompleto(Lead lead);
  // TODO: conectar a SP real cuando se defina — '[CRM].[SP_ContactoDetalleLst]'
  Future<ContactoDetalle> obtenerDetalleContacto(int idContacto);
  // TODO: conectar a SP real cuando se defina — '[CRM].[SP_NegociacionesPorContacto]'
  Future<List<Negociacion>> obtenerNegociaciones(int idLead);
}
