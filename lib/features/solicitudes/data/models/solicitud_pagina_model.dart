// lib/features/solicitudes/data/models/solicitud_pagina_model.dart
//
// Parser de la respuesta del task 'LSP' (CRM.CSV_SOLICITUD_LST_APP). Formato:
//
//   primera página : "sinValidar¦validados" ¯ porAsesor ¯ filas...
//   siguientes     : filas...
//   porAsesor      : codUser¦ibValidado¦cantidad ¬ ...  (puede venir vacío)
//   filas          : registro ¬ registro ¬ ...   (24 campos ¦ por registro)
//   error del SP   : "ERR¦numero¦mensaje"
//   sin datos      : ""  (ApiEmpty)
//
// 2026-09-11: se agregó el bloque porAsesor (conteos del picker "Asesores").
// Se sigue aceptando la forma vieja de 2 bloques por si la app corre contra un
// SP aún no desplegado — en ese caso conteosPorAsesor queda null.
//
// Layout de campos por fila (0..23) — 0..22 IGUAL a 'LS' + 23 idCampania:
//   00 NUMSOL *cursor*   01 NOMBRES        02 APE_PATERNO      03 APE_MATERNO
//   04 NOMEMPRE          05 CARGO          06 CELULAR          07 CORREO
//   08 tipoPersona       09 idCondPago     10 condPago         11 IMP_TOTAL
//   12 FC_ULTIMA (126) *cursor*           13 FC_USUARIO_C (126)
//   14 ID_OPORTUNIDAD    15 NOMBRE_OPORT   16 ID_CANAL         17 DES_CANAL
//   18 ID_ESTADO_GES     19 DESC_ESTADO    20 IB_VALIDADO
//   21 ID_USUARIO_EJEC   22 NOMUSER
//   23 ID_CAMPANIA (de CRM.T_OPORTUNIDAD, la misma por la que filtra el SP)
//
// 2026-09-10: se eliminaron los campos 24 ID_EVENTO / 25 NOMBRE_EVENTO — el
// filtro de la lista pasó de Campaña→Evento a Campaña→Oportunidad (igual que la
// web), y EVT.T_EVENTO ya no participa en el task 'LSP'.
//
// El CURSOR de la página siguiente = campo 12 (FC_ULTIMA) + campo 00 (NUMSOL).

import 'package:flutter/foundation.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';
import 'package:app_crm/features/solicitudes/domain/entities/solicitud_pagina.dart';

class SolicitudPaginaModel {
  const SolicitudPaginaModel._();

  static SolicitudPagina parse(String raw) {
    final texto = raw.trim();
    if (texto.isEmpty) return SolicitudPagina.vacia;

    if (texto.startsWith('ERR${AppConstants.sepCampos}')) {
      final p = texto.split(AppConstants.sepCampos);
      final msg = p.length > 2 && p[2].trim().isNotEmpty
          ? p[2].trim()
          : 'Error del servidor';
      throw AppException('No se pudo cargar las solicitudes. ($msg)');
    }

    final bloques = raw.split(AppConstants.sepListas);
    SolicitudConteos? conteos;
    Map<String, Map<bool, int>>? conteosPorAsesor;
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

    final items = filasRaw
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map(_parseFila)
        .whereType<Solicitud>()
        .toList();

    final ultima = items.isEmpty ? null : items.last;
    return SolicitudPagina(
      items: items,
      conteos: conteos,
      conteosPorAsesor: conteosPorAsesor,
      cursorFecha: ultima?.fechaCreacion,
      cursorNumsol: ultima?.idSolicitud,
    );
  }

  static SolicitudConteos _parseConteos(String raw) {
    final f = raw.split(AppConstants.sepCampos);
    return SolicitudConteos(
      sinValidar: ParseUtils.toInt(f, 0),
      validados: ParseUtils.toInt(f, 1),
    );
  }

  /// "codUser¦ibValidado¦cantidad ¬ ..." → {codUser: {ibValidado: cantidad}}.
  /// Bloque vacío = mapa vacío (no null): el SP sí respondió, simplemente no
  /// hay filas en el universo filtrado.
  static Map<String, Map<bool, int>> _parsePorAsesor(String raw) {
    final conteos = <String, Map<bool, int>>{};
    for (final registro in raw.split(AppConstants.sepRegistros)) {
      if (registro.trim().isEmpty) continue;
      final f = registro.split(AppConstants.sepCampos);
      final codUser = ParseUtils.str(f, 0);
      if (codUser.isEmpty) continue;
      conteos
          .putIfAbsent(codUser, () => {})
          .update(
            ParseUtils.toBool(f, 1),
            (cant) => cant + ParseUtils.toInt(f, 2),
            ifAbsent: () => ParseUtils.toInt(f, 2),
          );
    }
    return conteos;
  }

  static Solicitud? _parseFila(String raw) {
    try {
      final f = raw.split(AppConstants.sepCampos);
      return Solicitud(
        idSolicitud: ParseUtils.str(f, 0),
        nombre: ParseUtils.str(f, 1),
        apellidoPaterno: ParseUtils.str(f, 2),
        apellidoMaterno: ParseUtils.str(f, 3),
        nombreEmpresa: ParseUtils.str(f, 4),
        cargo: ParseUtils.str(f, 5),
        telefono: ParseUtils.str(f, 6),
        correo: ParseUtils.str(f, 7),
        tipoPersona: ParseUtils.str(f, 8),
        idCondicionPago: ParseUtils.str(f, 9),
        condicionPago: ParseUtils.str(f, 10),
        monto: ParseUtils.toDouble(f, 11),
        // Campo 12 = FC_ULTIMA (ISO 126) — es también el cursor de la página
        // siguiente. La card lo formatea igual que antes.
        fechaCreacion: ParseUtils.str(f, 12),
        idOportunidad: ParseUtils.toInt(f, 14),
        oportunidad: ParseUtils.str(f, 15),
        idCampania: ParseUtils.toInt(f, 23),
        idCanal: ParseUtils.toInt(f, 16),
        canal: ParseUtils.str(f, 17),
        idEstado: ParseUtils.toInt(f, 18),
        estado: ParseUtils.str(f, 19),
        ibValidado: ParseUtils.toBool(f, 20),
        asesor: ParseUtils.str(f, 21),
        nombreAsesor: ParseUtils.str(f, 22),
      );
    } catch (e) {
      debugPrint('SolicitudPaginaModel: fila descartada — $e');
      return null;
    }
  }
}
