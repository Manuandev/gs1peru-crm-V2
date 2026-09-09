// lib/features/cobranza/data/models/cobranza_pagina_model.dart
//
// Parser de la respuesta del task 'LSP' de CRM.CSV_COBRANZAS_LST_APP. Formato:
//
//   primera página : "total¦c2¦c0¦c5¦c3¦pendGlobal" ¯ filas...
//   siguientes     : filas...
//   filas          : registro ¬ registro ¬ ...   (24 campos ¦ por registro)
//   error del SP   : "ERR¦numero¦mensaje"
//   sin datos      : ""  (ApiEmpty → CobranzaPagina.vacia)
//
// Cada fila tiene los mismos 23 campos (0..22) que el task 'LS' (se reusa
// CobranzaModel.fromRawString sin cambios) + el campo 23 = FC_USUARIO_C en
// ISO 126, que es el CURSOR de la página siguiente (junto al NUMSOL, campo 0,
// de la última fila).

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaPaginaModel {
  const CobranzaPaginaModel._();

  static const String _prefijoError = 'ERR';
  static const int _idxCursorFecha = 23;

  static CobranzaPagina parse(String raw) {
    final texto = raw.trim();
    if (texto.isEmpty) return CobranzaPagina.vacia;

    if (texto.startsWith('$_prefijoError${AppConstants.sepCampos}')) {
      final p = texto.split(AppConstants.sepCampos);
      final msg = p.length > 2 && p[2].trim().isNotEmpty
          ? p[2].trim()
          : 'Error del servidor';
      throw AppException('No se pudieron cargar las cobranzas. ($msg)');
    }

    final bloques = raw.split(AppConstants.sepListas);
    CobranzaConteos? conteos;
    String filasRaw;
    if (bloques.length >= 2) {
      conteos = _parseConteos(bloques.first);
      filasRaw = bloques.sublist(1).join(AppConstants.sepListas);
    } else {
      filasRaw = raw;
    }

    final registros = filasRaw
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .toList();

    final items = registros
        .map((r) => CobranzaModel.fromRawString(r) as Cobranza)
        .toList();

    String? cursorFecha;
    String? cursorNumSol;
    if (registros.isNotEmpty) {
      final ultima = registros.last.split(AppConstants.sepCampos);
      cursorFecha = ParseUtils.str(ultima, _idxCursorFecha);
      cursorNumSol = ParseUtils.str(ultima, 0);
      if (cursorFecha.isEmpty) cursorFecha = null;
      if (cursorNumSol.isEmpty) cursorNumSol = null;
    }

    return CobranzaPagina(
      items: items,
      conteos: conteos,
      cursorFecha: cursorFecha,
      cursorNumSol: cursorNumSol,
    );
  }

  static CobranzaConteos _parseConteos(String raw) {
    final f = raw.split(AppConstants.sepCampos);
    return CobranzaConteos(
      total: ParseUtils.toInt(f, 0),
      facturar: ParseUtils.toInt(f, 1),
      pendDocumento: ParseUtils.toInt(f, 2),
      pendPago: ParseUtils.toInt(f, 3),
      cancelado: ParseUtils.toInt(f, 4),
      pendGlobal: ParseUtils.toInt(f, 5),
    );
  }
}
