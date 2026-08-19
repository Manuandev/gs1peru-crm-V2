// lib/features/cobranza/presentation/utils/resolver_moneda.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

// TC.MONEDA (facturación) guarda el id (varchar) de MonedaItem, no el
// símbolo — hay que resolverlo contra CatalogsBloc.monedas (parte [7] de
// lstListas). Si el catálogo no cargó o el id no matchea, se devuelve el id
// crudo como fallback en vez de dejarlo vacío.
String resolverSimboloMoneda(BuildContext context, String idMoneda) {
  if (idMoneda.isEmpty) return '';
  final state = context.watch<CatalogsBloc>().state;
  if (state is! CatalogsLoaded) return idMoneda;
  final item = state.monedas.where((m) => m.id == idMoneda).firstOrNull;
  return item?.simbolo ?? idMoneda;
}

// Mismo criterio de resolución que resolverSimboloMoneda (match por
// MonedaItem.id, no hardcodear ningún id de moneda) — usado para saber si
// hay que convertir un monto a soles con el tipo de cambio antes de aplicar
// la regla de detracción (ver cobranza/CLAUDE.md). `false` si el catálogo no
// cargó o el id no matchea ningún registro (asume soles, sin conversión).
bool esMonedaDolares(List<MonedaItem> monedas, String idMoneda) {
  if (idMoneda.isEmpty) return false;
  final item = monedas.where((m) => m.id == idMoneda).firstOrNull;
  return item?.codigo == 'USD';
}
