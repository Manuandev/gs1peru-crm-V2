// lib/features/solicitudes/domain/entities/solicitud_pagina.dart
//
// Resultado de UNA página del task 'LSP' de CRM.CSV_SOLICITUD_LST_APP
// (Solicitudes paginado por cursor/keyset). Mismo patrón que SeguimientoPagina.
//
// - items      : filas de esta página (Solicitud, reusada tal cual).
// - conteos    : "Sin validar" / "Validados" — SOLO en la primera página / refresh.
//                null en las siguientes.
// - conteosPorAsesor : {codUser: {ibValidado: cantidad}} para el picker
//                "Asesores" — SOLO en la primera página, null en las siguientes.
// - cursorFecha / cursorNumsol : llave para la página siguiente (FC_ULTIMA +
//                NUMSOL de la última fila). null si vino vacía.

import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';

/// Contadores de la cabecera de Solicitudes — calculados 100% en la base
/// (task 'LSP'). Aplican el filtro del panel (fecha/campaña/evento), NO el chip.
class SolicitudConteos {
  final int sinValidar;
  final int validados;

  const SolicitudConteos({this.sinValidar = 0, this.validados = 0});
}

class SolicitudPagina {
  final List<Solicitud> items;
  final SolicitudConteos? conteos;

  /// {codUser: {ibValidado: cantidad}} — lo calcula el SP sobre TODO el universo
  /// filtrado, no sobre las páginas cargadas. null en las páginas siguientes.
  final Map<String, Map<bool, int>>? conteosPorAsesor;
  final String? cursorFecha;
  final String? cursorNumsol;

  const SolicitudPagina({
    required this.items,
    this.conteos,
    this.conteosPorAsesor,
    this.cursorFecha,
    this.cursorNumsol,
  });

  static const SolicitudPagina vacia = SolicitudPagina(items: []);
}
