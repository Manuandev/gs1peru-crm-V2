// lib/features/cobranza/presentation/utils/resolver_moneda.dart

import 'package:flutter/material.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

// Bug real corregido (2026-08-19) — el SP de cobranza (`CSV_COBRANZAS_LST_APP`,
// tasks 'LS'/'DT') no mandaba el id real del catálogo (`codargu`) para
// moneda, solo `MN.descorta` (el símbolo corto, "S/"/"$.") — comparar eso
// contra `MonedaItem.id` nunca matcheaba nada. Pedido explícito del usuario:
// comparar SIEMPRE por id, nunca por texto/descripción — se agregó
// `MN.codargu` como campo nuevo al SP (`Cobranza.monedaId`/
// `CobranzaDetalle.monedaId`, ver cobranza/CLAUDE.md) y estas 2 funciones
// reciben ese id, no el símbolo.
String resolverSimboloMoneda(BuildContext context, String idMoneda) {
  if (idMoneda.isEmpty) return '';
  final state = context.watch<CatalogsBloc>().state;
  if (state is! CatalogsLoaded) return idMoneda;
  final item = state.monedas.where((m) => m.id == idMoneda).firstOrNull;
  return item?.simbolo ?? idMoneda;
}

// Usado para saber si hay que convertir un monto a soles con el tipo de
// cambio antes de aplicar la regla de detracción (ver cobranza/CLAUDE.md).
// `false` si el catálogo no cargó o el id no matchea ningún registro (asume
// soles, sin conversión).
bool esMonedaDolares(List<MonedaItem> monedas, String idMoneda) {
  if (idMoneda.isEmpty) return false;
  final item = monedas.where((m) => m.id == idMoneda).firstOrNull;
  return item?.codigo == 'USD';
}
