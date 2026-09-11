// lib/features/cobranza/data/models/cobranza_pagina_model.dart
//
// Parser de la respuesta del task 'LSP' de CRM.CSV_COBRANZAS_LST_APP. Formato:
//
//   primera página : "total¦c2¦c0¦c5¦c3¦pendGlobal" ¯ porAsesor ¯ filas...
//   siguientes     : filas...
//   porAsesor      : codUser¦idEstadoGes¦cantidad ¬ ...  (puede venir vacío)
//   filas          : registro ¬ registro ¬ ...   (24 campos ¦ por registro)
//   error del SP   : "ERR¦numero¦mensaje"
//   sin datos      : ""  (ApiEmpty → CobranzaPagina.vacia)
//
// 2026-09-11: se agregó el bloque porAsesor (conteos del picker "Asesores").
// Se sigue aceptando la forma vieja de 2 bloques por si la app corre contra un
// SP aún no desplegado — en ese caso conteosPorAsesor queda null.
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
    Map<String, Map<int, int>>? conteosPorAsesor;
    String filasRaw;
    if (bloques.length >= 3) {
      conteos = _parseConteos(bloques[0]);
      conteosPorAsesor = _parsePorAsesor(bloques[1]);
      filasRaw = bloques.sublist(2).join(AppConstants.sepListas);
    } else if (bloques.length == 2) {
      // SP sin el bloque porAsesor (versión anterior al 11/09/2026).
      conteos = _parseConteos(bloques[0]);
      filasRaw = bloques[1];
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
      conteosPorAsesor: conteosPorAsesor,
      cursorFecha: cursorFecha,
      cursorNumSol: cursorNumSol,
    );
  }

  /// "codUser¦idEstadoGes¦cantidad ¬ ..." → {codUser: {idEstadoGes: cantidad}}.
  /// Bloque vacío = mapa vacío (no null): el SP sí respondió, simplemente no
  /// hay filas en el universo filtrado.
  static Map<String, Map<int, int>> _parsePorAsesor(String raw) {
    final conteos = <String, Map<int, int>>{};
    for (final registro in raw.split(AppConstants.sepRegistros)) {
      if (registro.trim().isEmpty) continue;
      final f = registro.split(AppConstants.sepCampos);
      final codUser = ParseUtils.str(f, 0);
      if (codUser.isEmpty) continue;
      conteos
          .putIfAbsent(codUser, () => {})
          .update(
            ParseUtils.toInt(f, 1),
            (cant) => cant + ParseUtils.toInt(f, 2),
            ifAbsent: () => ParseUtils.toInt(f, 2),
          );
    }
    return conteos;
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
