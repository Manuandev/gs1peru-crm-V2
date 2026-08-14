// lib/features/lead/domain/repositories/lead_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

abstract class LeadRepository {
  Future<List<ContactoNegociacion>> getLeads();
  Future<Negociacion> getLeadDetalle(int idLead);
  // Task 'NEG' — datos mínimos para prellenar el paso 1 del wizard de
  // "Generar solicitud" (solicitudes/) al crear desde una negociación. Ver
  // DatosPrellenadoSolicitud/lead_remote_datasource.dart.
  Future<DatosPrellenadoSolicitud> getDatosPrellenadoSolicitud(int idLead);
  // Task 'DN' — mismo detalle que getLeadDetalle, pero anclado en idContacto
  // (el lead más reciente de ese contacto). Usa Seguimiento ("Ver detalle").
  // 2026-08-03 — migrado de idNumero a idContacto: un lead siempre tiene
  // contacto (T_LEAD.ID_CONTACTO), el número puede cambiar/duplicarse.
  Future<Negociacion> getLeadDetallePorContacto(int idContacto);
  // idContacto — 2026-08-03: antes era idNumero, pero CSV_LEADS_CUD_APP
  // (task 'U') parsea este campo como @ID_CONTACTO y lo graba directo en
  // T_LEAD.ID_CONTACTO (bug real corregido, ver Negociacion.idContacto).
  Future<CrudResult> updateNegociacion(Negociacion negociacion, int idContacto);
  // SP 'LN' — historial de negociaciones (leads) del mismo CONTACTO.
  // 2026-08-03 — migrado de idNumero a idContacto (mismo motivo que
  // getLeadDetallePorContacto arriba).
  Future<List<Negociacion>> obtenerNegociaciones(int idContacto);
  // SP 'LHC' — historial unificado (seguimiento + comentario + recordatorio)
  // de todos los leads activos del mismo CONTACTO. 2026-08-13 — reemplaza a
  // 'LHN' (solo seguimiento), ver lead_remote_datasource.dart.
  Future<List<HistorialComentario>> obtenerHistorialSeguimientoPorContacto(
    int idContacto,
  );
  // SP 'LRN' — recordatorios futuros de todos los leads del mismo CONTACTO,
  // ordenados por fecha ascendente. Usado por el tab "Recordatorios" y la
  // card "Próximo recordatorio" de Información.
  Future<List<LeadRecordatorio>> obtenerRecordatoriosPorContacto(
    int idContacto,
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
  // lead/CLAUDE.md). Ancla en idContacto (migrado de idNumero 2026-08-03).
  // Contacto en blanco (idContacto == 0) si todavía no existe.
  Future<ContactoSimple> getContactoSimplePorIdContacto(int idContacto);
  Future<CrudResult> guardarContactoSimple(ContactoSimple contacto);
}
