// lib/core/utils/documento_validation_utils.dart

import 'package:flutter/services.dart';

import 'package:app_crm/core/index_core.dart';

// Reglas de validación de N° documento según el tipo elegido (longitud
// máxima + si acepta solo dígitos) — mismos ids reales de
// `CatalogsBloc.valoresDefecto` (parte [13] del SP, SYSTABEXTER02
// CODTABLA='F01'), nunca hardcodear '1'/'4'/'6'/'7'. Único lugar para esta
// regla — cualquier formulario con un campo de documento (Datos del
// solicitante, Facturación, Nuevo participante...) debe usar esto en vez de
// reimplementar su propio mapeo tipo → longitud/teclado.
class DocumentoValidationUtils {
  DocumentoValidationUtils._();

  static int? maxLength(String? tipoDocId, ValoresCRMItem v) {
    if (tipoDocId == null || tipoDocId.isEmpty) return null;
    if (tipoDocId == v.idTipoDocDni) return 8;
    if (tipoDocId == v.idTipoDocCde) return 12;
    if (tipoDocId == v.idTipoDocRuc) return 11;
    if (tipoDocId == v.idTipoDocPas) return 12;
    return null;
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
