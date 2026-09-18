// lib/core/utils/documento_validation_utils.dart

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:app_crm/core/index_core.dart';

// Reglas de validación de N° documento según el tipo elegido (longitud,
// longitud exacta, solo dígitos, cuándo buscar en la base). Único lugar para
// esta regla — cualquier formulario con un campo de documento (Datos del
// solicitante, Facturación, Nuevo participante, EditContacto,
// EditContactoSimple) debe usar esto en vez de reimplementar su propio mapeo.
//
// Desde 2026-09-14 todo sale de PARTIDAM del catálogo (TipoDocumentoItem,
// parte [10] del SP lstListas): longitud, tipoCaracter (N = solo dígitos) y
// longitudExacta. `valoresDefecto` solo se usa como respaldo si el SP
// desplegado todavía no manda PARTIDAM (`tieneReglas == false`).
class DocumentoValidationUtils {
  DocumentoValidationUtils._();

  static TipoDocumentoItem? _tipo(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento,
  ) {
    if (tipoDocId == null || tipoDocId.isEmpty) return null;
    return tiposDocumento.where((t) => t.id == tipoDocId).firstOrNull;
  }

  // Longitud máxima (o exacta) del tipo — `null` = sin tope.
  static int? maxLength(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento, [
    ValoresCRMItem? valoresDefecto,
  ]) {
    if (tipoDocId == null || tipoDocId.isEmpty) return null;
    final tipo = _tipo(tipoDocId, tiposDocumento);
    if (tipo != null && tipo.canCaracteresMax > 0) return tipo.canCaracteresMax;
    // Respaldo si el tipo no trae el dato (SP viejo o fila nueva del catálogo).
    if (valoresDefecto == null) return null;
    if (tipoDocId == valoresDefecto.idTipoDocDni) return 8;
    if (tipoDocId == valoresDefecto.idTipoDocRuc) return 11;
    if (tipoDocId == valoresDefecto.idTipoDocCde) return 9;
    if (tipoDocId == valoresDefecto.idTipoDocPas) return 12;
    return null;
  }

  // Trunca un N° documento ya cargado (backend, negociación) al máximo del
  // tipo — `maxLength` del widget solo limita lo que el usuario TIPEA; un
  // valor asignado directo a `controller.text` no pasa por los formatters.
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

  // tipoCaracter 'N' de PARTIDAM.
  static bool soloDigitos(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento, [
    ValoresCRMItem? valoresDefecto,
  ]) {
    final tipo = _tipo(tipoDocId, tiposDocumento);
    if (tipo != null && tipo.tieneReglas) return tipo.soloNumeros;
    if (valoresDefecto == null) return false;
    return tipoDocId == valoresDefecto.idTipoDocDni ||
        tipoDocId == valoresDefecto.idTipoDocRuc;
  }

  static TextInputType keyboardType(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento, [
    ValoresCRMItem? valoresDefecto,
  ]) => soloDigitos(tipoDocId, tiposDocumento, valoresDefecto)
      ? TextInputType.number
      : TextInputType.text;

  static List<TextInputFormatter>? inputFormatters(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento, [
    ValoresCRMItem? valoresDefecto,
  ]) => soloDigitos(tipoDocId, tiposDocumento, valoresDefecto)
      ? [FilteringTextInputFormatter.digitsOnly]
      : null;

  // esJuridico de PARTIDAM — decide Razón social vs Nombres/Apellidos en
  // Facturación (2026-09-14). Con SP viejo cae al criterio anterior (es RUC).
  static bool esJuridico(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento,
    ValoresCRMItem valoresDefecto,
  ) {
    final tipo = _tipo(tipoDocId, tiposDocumento);
    if (tipo != null && tipo.tieneReglas) return tipo.esJuridico;
    return tipoDocId != null &&
        tipoDocId.isNotEmpty &&
        tipoDocId == valoresDefecto.idTipoDocRuc;
  }

  // PARTIDAM "Nacional" (DNI, RUC) — con un tipo nacional la nacionalidad es
  // siempre la peruana y el combo se oculta (Datos del solicitante,
  // 2026-09-18). Sin tipo elegido o tipo desconocido → false (se muestra).
  static bool esNacional(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento,
  ) => _tipo(tipoDocId, tiposDocumento)?.esNacional ?? false;

  static bool esRuc(String? tipoDocId, ValoresCRMItem valoresDefecto) =>
      tipoDocId != null &&
      tipoDocId.isNotEmpty &&
      tipoDocId == valoresDefecto.idTipoDocRuc;

  // N° documento obligatorio con cualquier tipo salvo "Sin documento" —
  // pedido de negocio 2026-09-18. El "sin documento" vigente es el "0"
  // (DOC.TRIB.NO.DOM.SIN.RUC, `idTipDocSnr`); el "S" (`idTipoDocSnd`) ya no
  // se usa, por eso no se considera.
  static bool numeroRequerido(
    String? tipoDocId,
    ValoresCRMItem valoresDefecto,
  ) {
    if (tipoDocId == null || tipoDocId.isEmpty) return false;
    return tipoDocId != valoresDefecto.idTipDocSnr;
  }

  // "Debe tener N dígitos/caracteres" cuando el tipo exige longitud exacta
  // (PARTIDAM longitudExacta = 1). Vacío no se valida acá — eso lo decide
  // cada formulario (`requerido` en [validador]).
  static String? validarLongitud(
    String? tipoDocId,
    String? valor,
    List<TipoDocumentoItem> tiposDocumento,
  ) {
    final texto = (valor ?? '').trim();
    if (texto.isEmpty) return null;
    final tipo = _tipo(tipoDocId, tiposDocumento);
    if (tipo == null || !tipo.longitudExacta || tipo.canCaracteresMax <= 0) {
      return null;
    }
    if (texto.length == tipo.canCaracteresMax) return null;
    final unidad = tipo.soloNumeros ? 'dígitos' : 'caracteres';
    return 'Debe tener ${tipo.canCaracteresMax} $unidad';
  }

  static FormFieldValidator<String> validador(
    String? tipoDocId,
    List<TipoDocumentoItem> tiposDocumento, {
    bool requerido = false,
  }) => (v) {
    if (requerido && (v == null || v.trim().isEmpty)) return 'Requerido';
    return validarLongitud(tipoDocId, v, tiposDocumento);
  };

  // La búsqueda en la base (Clientes/BuscarDocumento) solo aplica a DNI —
  // pedido de negocio 2026-09-14: otro tipo con los mismos 8 dígitos (ej.
  // Carnet de extranjería) NO busca. Además el número tiene que estar
  // completo (longitud del tipo).
  static bool puedeBuscar(
    String? tipoDocId,
    String numDoc,
    List<TipoDocumentoItem> tiposDocumento,
    ValoresCRMItem valoresDefecto,
  ) {
    if (tipoDocId == null ||
        tipoDocId.isEmpty ||
        tipoDocId != valoresDefecto.idTipoDocDni) {
      return false;
    }
    final longitud =
        maxLength(tipoDocId, tiposDocumento, valoresDefecto) ?? 8;
    return numDoc.trim().length == longitud;
  }
}
