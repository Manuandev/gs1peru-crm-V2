// lib/features/lead/data/models/seguimiento_pagina_model.dart
//
// Parser de la respuesta del task 'LSP' (CRM.CSV_LEADS_LST_APP). Formato:
//
//   primera página : "total¦nuevos¦desarrollo¦propuesta¦activos" ¯ filas...
//   siguientes     : filas...
//   filas          : registro ¬ registro ¬ ...   (36 campos ¦ por registro)
//   error del SP   : "ERR¦numero¦mensaje"
//   sin datos      : ""  (ApiEmpty)
//
// Layout de campos por fila (0..35) — mismo que 'LS' 0..34 + 35 nuevo:
//   00 ID_LEAD           01 ID_CONTACTO       02 NOMBRES         03 APELLIDO_P
//   04 APELLIDO_M        05 EMPRESA           06 ASESOR          07 FC_ULTIMA (126) *cursor*
//   08 ID_NUMERO         09 PREFIJO_PAIS      10 NUMERO          11 IB_FAVORITO
//   12 CORREO            13 ID_ESTADO_EFEC    14 DESC_ESTADO_EFEC
//   15 ID_ESTADO_PADRE   16 DESC_ESTADO_PADRE 17 ID_CAMPANIA     18 NOMBRE_CAMPANIA
//   19 ID_OPORTUNIDAD    20 NOMBRE_OPORT      21 ID_CANAL        22 NOMBRE_CANAL
//   23 ID_INTERES        24 DESC_INTERES      25 CONV_ABIERTA(0/1)
//   26 DC_PRECIO_BASE    27 DC_PRECIO         28 IN_PARTICIPANTES 29 DC_DESCUENTO
//   30 FC_USUARIO_C(126) 31 ID_CONVERSACION_CAB
//   32 NOM_CARGO         33 ID_TIP_MONEDA     34 CT_LEADS        35 FC_PRIMER_MSJ_CLI (126)
//
// El CURSOR de la página siguiente = campo 07 (FC_ULTIMA) + campo 01
// (ID_CONTACTO) de la ÚLTIMA fila.

import 'package:flutter/foundation.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoPaginaModel {
  const SeguimientoPaginaModel._();

  static const String _prefijoError = 'ERR';

  static SeguimientoPagina parse(String raw) {
    final texto = raw.trim();
    if (texto.isEmpty) return SeguimientoPagina.vacia;

    // Error devuelto por el TRY/CATCH del SP (no como excepción de ADO.NET).
    if (texto.startsWith('$_prefijoError${AppConstants.sepCampos}')) {
      final p = texto.split(AppConstants.sepCampos);
      final msg = p.length > 2 && p[2].trim().isNotEmpty
          ? p[2].trim()
          : 'Error del servidor';
      throw AppException('No se pudo cargar el seguimiento. ($msg)');
    }

    // Bloques ¯: si hay 2+, el primero son los contadores (solo 1ra página).
    final bloques = raw.split(AppConstants.sepListas);
    SeguimientoConteos? conteos;
    String filasRaw;
    if (bloques.length >= 2) {
      conteos = _parseConteos(bloques.first);
      filasRaw = bloques.sublist(1).join(AppConstants.sepListas);
    } else {
      filasRaw = raw;
    }

    final items = filasRaw
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map(_parseFila)
        .whereType<ContactoNegociacion>()
        .toList();

    final ultima = items.isEmpty ? null : items.last;
    return SeguimientoPagina(
      items: items,
      conteos: conteos,
      cursorFecha: ultima?.negociacion.fechaHoraInteraccion,
      cursorIdContacto: ultima?.contacto.idContacto,
    );
  }

  static SeguimientoConteos _parseConteos(String raw) {
    final f = raw.split(AppConstants.sepCampos);
    return SeguimientoConteos(
      total: ParseUtils.toInt(f, 0),
      nuevos: ParseUtils.toInt(f, 1),
      enDesarrollo: ParseUtils.toInt(f, 2),
      propuesta: ParseUtils.toInt(f, 3),
      activos: ParseUtils.toInt(f, 4),
    );
  }

  /// Una fila corrupta se descarta (null) y se loguea — nunca tumba la página
  /// entera ni la pantalla.
  static ContactoNegociacion? _parseFila(String raw) {
    try {
      final f = raw.split(AppConstants.sepCampos);

      final contacto = Contacto(
        idContacto: ParseUtils.toInt(f, 1),
        nombre: ParseUtils.str(f, 2),
        apellidoPaterno: ParseUtils.str(f, 3),
        apellidoMaterno: ParseUtils.str(f, 4),
        nombreEmpresa: ParseUtils.str(f, 5),
        asesor: ParseUtils.str(f, 6),
        cargo: ParseUtils.strNullable(f, 32),
        correo: ParseUtils.strNullable(f, 12),
      );

      final numero = Numero(
        idNumero: ParseUtils.toInt(f, 8),
        prefijo: ParseUtils.str(f, 9),
        numero: ParseUtils.str(f, 10),
        isFavorito: ParseUtils.toBool(f, 11),
        tieneConversacionAbierta: ParseUtils.toBool(f, 25),
        idChatCab: ParseUtils.toInt(f, 31),
        fechaPrimerMensajeCliente: ParseUtils.str(f, 35),
      );

      final negociacion = Negociacion(
        idLead: ParseUtils.toInt(f, 0),
        nombre: '',
        modalidad: '',
        cantidad: ParseUtils.toInt(f, 28),
        precioBase: ParseUtils.toDouble(f, 26),
        descuento: ParseUtils.toDouble(f, 29),
        precio: ParseUtils.toDouble(f, 27),
        fechaHoraInteraccion: ParseUtils.str(f, 7),
        fechaHoraCreacion: ParseUtils.str(f, 30),
        idEstado: ParseUtils.str(f, 13),
        descripcionEstado: ParseUtils.str(f, 14),
        idEstadoPadre: ParseUtils.str(f, 15),
        descripcionEstadoPadre: ParseUtils.str(f, 16),
        idCampania: ParseUtils.toInt(f, 17),
        nombreCampania: ParseUtils.str(f, 18),
        idOportunidad: ParseUtils.toInt(f, 19),
        nombreOportunidad: ParseUtils.str(f, 20),
        idCanal: ParseUtils.toInt(f, 21),
        descripcionCanal: ParseUtils.str(f, 22),
        idInteres: ParseUtils.toInt(f, 23),
        descripcionInteres: ParseUtils.str(f, 24),
        activo: true,
        idContacto: ParseUtils.toInt(f, 1),
        idMoneda: ParseUtils.str(f, 33),
        totalLeadsNumero: ParseUtils.toInt(f, 34),
      );

      return ContactoNegociacion(
        contacto: contacto,
        numero: numero,
        negociacion: negociacion,
        totalLeads: ParseUtils.toInt(f, 34),
      );
    } catch (e) {
      debugPrint('SeguimientoPaginaModel: fila descartada — $e');
      return null;
    }
  }
}
