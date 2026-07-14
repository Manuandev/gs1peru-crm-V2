// lib/features/lead/domain/repositories/lead_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadRepository {
  Future<List<ContactoNegociacion>> getLeads();
  Future<Negociacion> getLeadDetalle(int idLead);
  // Task 'DN' — mismo detalle que getLeadDetalle, pero anclado en idNumero
  // (el lead más reciente de ese número). Usa Seguimiento ("Ver detalle").
  Future<Negociacion> getLeadDetallePorNumero(int idNumero);
  Future<CrudResult> updateNegociacion(Negociacion negociacion, int idNumero);
  // SP 'LN' — historial de negociaciones (leads) del mismo número
  Future<List<Negociacion>> obtenerNegociaciones(int idNumero);
  // SP 'LCG' — historial de comentarios de todos los leads del mismo número
  Future<List<HistorialComentario>> obtenerHistorialComentarios(int idNumero);
  // SP 'LH' — historial de seguimiento de un lead puntual
  Future<List<HistorialComentario>> obtenerHistorialSeguimiento(int idLead);
}
