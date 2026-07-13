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
