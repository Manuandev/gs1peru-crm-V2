// lib/core/utils/documento_validation_utils.dart

import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';

// Reglas de validación de N° documento según el tipo elegido (longitud
// máxima + si acepta solo dígitos). Único lugar para esta regla — cualquier
// formulario con un campo de documento (Datos del solicitante, Facturación,
// Nuevo participante, EditContacto...) debe usar esto en vez de reimplementar
// su propio mapeo tipo → longitud/teclado.
class DocumentoValidationUtils {
  DocumentoValidationUtils._();

  // Longitud máxima REAL del tipo de documento —
  // `TipoDocumentoItem.canCaracteresMax` (parte [10] del SP lstListas,
  // índice [4] del raw — ver core/CLAUDE.md). Antes era un mapa fijo por id
  // (DNI=8, CE=12, RUC=11, Pasaporte=12) que copiaba a mano un dato que el
  // catálogo real ya trae — se reemplazó (pedido de negocio 2026-07-29,
  // "revisa cuál es el máximo real de cada tipo de documento, en todas las
  // partes") para que cualquier ajuste de longitud en el backend se refleje
  // solo, sin tocar código acá. Si el tipo no está en la lista recibida o el
  // catálogo trae `canCaracteresMax` en 0, no hay tope (`null`).
  static int? maxLength(String? tipoDocId, List<TipoDocumentoItem> tiposDocumento) {
    if (tipoDocId == null || tipoDocId.isEmpty) return null;
    final tipo = tiposDocumento.where((t) => t.id == tipoDocId).firstOrNull;
    if (tipo == null || tipo.canCaracteresMax <= 0) return null;
    return tipo.canCaracteresMax;
  }

  static bool soloDigitos(String? tipoDocId, ValoresCRMItem v) =>
      tipoDocId == v.idTipoDocDni || tipoDocId == v.idTipoDocRuc;

  static TextInputType keyboardType(String? tipoDocId, ValoresCRMItem v) =>
      soloDigitos(tipoDocId, v) ? TextInputType.number : TextInputType.text;

  static List<TextInputFormatter>? inputFormatters(
    String? tipoDocId,
    ValoresCRMItem v,
  ) => soloDigitos(tipoDocId, v)
      ? [FilteringTextInputFormatter.digitsOnly]
      : null;
}
