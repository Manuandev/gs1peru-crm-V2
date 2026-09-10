// lib/features/home/domain/entities/notifications/notificaciones_pagina.dart
//
// Resultado de UNA página del task 'LS' de CRM.CSV_NOTIFICACIONES_LST_APP
// (notificaciones paginadas por cursor/keyset, 2026-09-10). Mismo patrón que
// SeguimientoPagina (task 'LSP' de CSV_LEADS_LST_APP).
//
// - items       : filas de esta página, ya agrupadas por el SP (los mensajes
//                 del mismo chat vienen colapsados en una sola con su
//                 `cantidad`; antes eso lo hacía el cliente).
// - conteos     : totales por chip. SOLO vienen en la primera página / refresh
//                 (el SP no los reenvía en cada scroll). null en las siguientes.
// - cursorFecha / cursorId : llave para pedir la página siguiente
//                 (FC_USUARIO_C en formato 126 + ID_NOTIFICACION de la última
//                 fila). null si la página vino vacía.

import 'package:app_crm/features/home/index_home.dart';

/// Contadores de la cabecera de Notificaciones — calculados 100% en la base,
/// nunca en el cliente (con paginación, `lista.length` solo ve la página
/// actual). NO aplican el chip activo: aunque estés viendo "Mensajes", el chip
/// "Actividades" sigue mostrando su total.
class NotificacionesConteos {
  final int todas;
  final int actividades;
  final int derivaciones;
  final int mensajes;

  /// Notificaciones sin leer (`IB_LEIDO = 0`) sobre el universo completo.
  /// Desde que la lista dejó de filtrar por leído (ver el header del SP) este
  /// es el único número que refleja "pendientes" — alimenta el badge.
  final int noLeidas;

  const NotificacionesConteos({
    this.todas = 0,
    this.actividades = 0,
    this.derivaciones = 0,
    this.mensajes = 0,
    this.noLeidas = 0,
  });
}

class NotificacionesPagina {
  final List<Notificacion> items;
  final NotificacionesConteos? conteos;
  final String? cursorFecha;
  final int? cursorId;

  const NotificacionesPagina({
    required this.items,
    this.conteos,
    this.cursorFecha,
    this.cursorId,
  });

  static const NotificacionesPagina vacia = NotificacionesPagina(items: []);
}
