// lib/features/lead/domain/entities/seguimiento_pagina.dart
//
// Resultado de UNA página del task 'LSP' de CRM.CSV_LEADS_LST_APP (Seguimiento
// paginado por cursor/keyset). Implementación NUEVA — no comparte nada con el
// task 'LS' viejo ni con LeadListBloc.
//
// - items      : filas de esta página, 1 por contacto (su negociación —lead—
//                más reciente no cerrada). Reusa la entidad pura
//                [ContactoNegociacion] (sin cambios) para que LeadCard funcione
//                tal cual.
// - conteos    : totales por estado. SOLO vienen en la primera página / refresh
//                (el SP no los reenvía en cada scroll). null en las siguientes.
// - cursorFecha / cursorIdContacto : llave para pedir la página siguiente
//                (FC_ULTIMA + ID_CONTACTO de la última fila). null si vino vacía.

import 'package:app_crm/features/lead/index_lead.dart';

/// Contadores de la cabecera de Seguimiento — calculados 100% en la base
/// (task 'LSP'), nunca en el cliente. Son totales del universo del asesor SIN
/// aplicar el chip activo (aunque estés viendo "Propuesta", "Nuevos" muestra su
/// total real). Unidad = contacto por su estado representativo (más reciente).
class SeguimientoConteos {
  final int total;
  final int nuevos;
  final int enDesarrollo;
  final int propuesta;

  /// No cerrados. Con 'LSP' == [total] (el SP ya excluye estado '04'); se
  /// mantiene explícito porque alimenta el badge "Seguimiento" del drawer.
  final int activos;

  const SeguimientoConteos({
    this.total = 0,
    this.nuevos = 0,
    this.enDesarrollo = 0,
    this.propuesta = 0,
    this.activos = 0,
  });

  /// Mapa que consumen [LeadListFilterChips] y [LeadListStatsRow] sin tocarlos.
  Map<LeadListFiltro, int> get comoMapa => {
    LeadListFiltro.todos: total,
    LeadListFiltro.nuevos: nuevos,
    LeadListFiltro.enDesarrollo: enDesarrollo,
    LeadListFiltro.propuesta: propuesta,
  };

  int paraFiltro(LeadListFiltro filtro) => switch (filtro) {
    LeadListFiltro.todos => total,
    LeadListFiltro.nuevos => nuevos,
    LeadListFiltro.enDesarrollo => enDesarrollo,
    LeadListFiltro.propuesta => propuesta,
  };
}

class SeguimientoPagina {
  final List<ContactoNegociacion> items;
  final SeguimientoConteos? conteos;
  final String? cursorFecha;
  final int? cursorIdContacto;

  const SeguimientoPagina({
    required this.items,
    this.conteos,
    this.cursorFecha,
    this.cursorIdContacto,
  });

  static const SeguimientoPagina vacia = SeguimientoPagina(items: []);
}
