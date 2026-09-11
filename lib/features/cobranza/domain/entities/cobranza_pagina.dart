// lib/features/cobranza/domain/entities/cobranza_pagina.dart
//
// Resultado de UNA página del task 'LSP' de CRM.CSV_COBRANZAS_LST_APP
// (paginado por cursor/keyset). Reusa la entidad pura [Cobranza] para que
// CobranzaCard funcione tal cual.
//
// - items     : filas de esta página.
// - conteos   : totales por estado (2/0/5/3) + total + pendiente global.
//               SOLO vienen en la primera página / refresh. null en las
//               siguientes.
// - conteosPorAsesor : {codUser: {idEstadoGes: cantidad}} para el picker
//               "Asesores" — SOLO en la primera página, null en las siguientes.
// - cursorFecha / cursorNumSol : llave para la página siguiente (FC_USUARIO_C
//               en ISO 126 + NUMSOL de la última fila). null si vino vacía.

import 'package:app_crm/features/cobranza/index_cobranza.dart';

/// Contadores de las 4 tarjetas de estado + total + pendiente global.
/// Calculados 100% en la base (task 'LSP'). Las 4 tarjetas (`facturar`/
/// `pendDocumento`/`pendPago`/`cancelado`) SÍ aplican el filtro del panel
/// (fecha/campaña/oportunidad) y el chip, pero NO el filtro de tarjetas en sí.
/// `pendGlobal` es la EXCEPCIÓN: número global (Pend. de documento sin ningún
/// filtro del panel) — alimenta el badge "Cobranza" del drawer.
class CobranzaConteos {
  final int total;
  final int facturar; // idEstado 2
  final int pendDocumento; // idEstado 0
  final int pendPago; // idEstado 5
  final int cancelado; // idEstado 3
  final int pendGlobal;

  const CobranzaConteos({
    this.total = 0,
    this.facturar = 0,
    this.pendDocumento = 0,
    this.pendPago = 0,
    this.cancelado = 0,
    this.pendGlobal = 0,
  });

  /// Mapa {idEstado: conteo} que consume [CobranzaSummaryCards] sin tocarlo.
  Map<int, int> get porEstado => {
    2: facturar,
    0: pendDocumento,
    5: pendPago,
    3: cancelado,
  };
}

class CobranzaPagina {
  final List<Cobranza> items;
  final CobranzaConteos? conteos;

  /// {codUser: {idEstadoGes: cantidad}} — lo calcula el SP sobre TODO el
  /// universo filtrado, no sobre las páginas cargadas. Se mueve con el panel,
  /// el chip y la búsqueda, pero NO con el asesor seleccionado ni con el filtro
  /// de tarjetas. null en las páginas siguientes.
  final Map<String, Map<int, int>>? conteosPorAsesor;
  final String? cursorFecha;
  final String? cursorNumSol;

  const CobranzaPagina({
    required this.items,
    this.conteos,
    this.conteosPorAsesor,
    this.cursorFecha,
    this.cursorNumSol,
  });

  static const CobranzaPagina vacia = CobranzaPagina(items: []);
}
