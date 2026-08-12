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
  // `valoresDefecto` es opcional por compatibilidad, pero SIEMPRE pasarlo
  // cuando esté disponible — es el fallback real (ver comentario abajo).
  static int? maxLength(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento, [
    ValoresCRMItem? valoresDefecto,
  ]) {
    if (tipoDocId == null || tipoDocId.isEmpty) return null;
    final tipo = tiposDocumento.where((t) => t.id == tipoDocId).firstOrNull;
    if (tipo != null && tipo.canCaracteresMax > 0) return tipo.canCaracteresMax;
    // Fallback — bug real encontrado en vivo el 2026-08-12: con DNI
    // seleccionado, el campo Número documento aceptaba dígitos sin límite.
    // Causa REAL (confirmada con datos reales del SP, no una suposición):
    // el SP sí manda `canCaracteresMax`, pero como decimal ("8.000",
    // "11.000"...) — el parser (`TipoDocumentoItemModel.fromRawString`,
    // `catalog_item_model.dart`) usaba `int.tryParse`, que falla con un
    // punto decimal y caía a `0` para TODO el catálogo. Ya corregido ahí
    // (`toDouble(...).toInt()`) — este fallback queda como red de
    // seguridad, no como el fix principal, por si algún tipo puntual
    // llegara sin el dato (fila nueva del catálogo, etc.). Valores reales
    // confirmados por el usuario (`SYSTABEXTER02 CODTABLA='F01'`): DNI=8,
    // RUC=11, Carnet de extranjería=9 (no 12, como decía una nota vieja
    // de este archivo), Pasaporte=12 — se usan solo si el catálogo no
    // trae el dato (`tipo == null` o `canCaracteresMax <= 0`), nunca
    // pisan un valor real ya parseado correctamente.
    if (valoresDefecto == null) return null;
    if (tipoDocId == valoresDefecto.idTipoDocDni) return 8;
    if (tipoDocId == valoresDefecto.idTipoDocRuc) return 11;
    if (tipoDocId == valoresDefecto.idTipoDocCde) return 9;
    if (tipoDocId == valoresDefecto.idTipoDocPas) return 12;
    return null;
  }

  // Trunca un N° documento ya cargado (backend, negociación, búsqueda por
  // documento) al máximo real del tipo — necesario porque `maxLength` del
  // widget solo limita lo que el usuario TIPEA (vía inputFormatters); un
  // valor asignado directo a un TextEditingController.text (`ctrl.text =
  // valor`) no pasa por esos formatters y Flutter no lo trunca solo. Sin
  // esto, un dato sucio en el backend (ej. un N° documento guardado sin
  // validación desde otra pantalla) se muestra completo aunque no calce con
  // el tipo de documento resuelto — 2026-08-12, encontrado en vivo con un
  // DNI de 17 dígitos prellenado desde una negociación.
  static String limitarLongitud(
    String? tipoDocId,
    String numDoc,
    List<TipoDocumentoItem> tiposDocumento, [
    ValoresCRMItem? valoresDefecto,
  ]) {
    final max = maxLength(tipoDocId, tiposDocumento, valoresDefecto);
    if (max == null || numDoc.length <= max) return numDoc;
    return numDoc.substring(0, max);
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
