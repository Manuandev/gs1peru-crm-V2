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
  // SP 'LHN' — historial de seguimiento de todos los leads activos del
  // mismo número
  Future<List<HistorialComentario>> obtenerHistorialSeguimientoPorNumero(
    int idNumero,
  );

  // ⚠️ PENDIENTE — endpoint de lectura aún sin confirmar con backend, ver
  // lead/CLAUDE.md. Contacto en blanco (idContacto == 0) si el número
  // todavía no tiene contacto asociado.
  Future<ContactoDetalle> getContactoPorIdNumero(int idNumero);
  // CRM.CSV_CONTACTO_CUD_APP — rama CREATE ya funciona; rama UPDATE
  // pendiente de reglas de negocio (ver lead/CLAUDE.md).
  Future<CrudResult> guardarContacto(ContactoDetalle contacto);

  // CRM.CSV_CONTACTO_LST_APP task 'DS' / CSV_CONTACTO_CUD_APP task 'US' —
  // pantalla EditContactoSimple (versión reducida de EditContacto, ver
  // lead/CLAUDE.md). Contacto en blanco (idContacto == 0) si el número
  // todavía no tiene contacto asociado.
  Future<ContactoSimple> getContactoSimplePorIdNumero(int idNumero);
  Future<CrudResult> guardarContactoSimple(ContactoSimple contacto);
}
