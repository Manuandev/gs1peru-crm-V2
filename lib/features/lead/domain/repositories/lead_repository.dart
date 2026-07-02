// lib/features/lead/domain/repositories/lead_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadRepository {
  Future<List<Lead>> getLeads();
  Future<LeadDetalle> getLeadDetalle(int idLead);
  Future<void> toggleFavorito(int idLead, bool isFavorito);
  Future<CrudResult> updateLeadCompleto(
    Lead lead, {
    String empresaEditar,
    String correoEditar,
    String nuevasEmpresas,
    String nuevosCorreos,
    String nuevosPrefijos,
    String nuevosNumeros,
  });
  // TODO: conectar a SP real cuando se defina — '[CRM].[SP_NegociacionesPorContacto]'
  Future<List<Negociacion>> obtenerNegociaciones(int idLead);
  // SP 'LCG' — historial de comentarios de todos los leads del mismo número
  Future<List<HistorialComentario>> obtenerHistorialComentarios(int idNumero);
}
