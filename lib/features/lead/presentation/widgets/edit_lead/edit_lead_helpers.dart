// lib/features/lead/presentation/widgets/edit_lead/edit_lead_helpers.dart

import 'package:app_crm/index_dependencies.dart';

/// Funciones puras de parseo y formato para el formulario de edición de lead.
class EditLeadHelpers {
  EditLeadHelpers._();

  static final _fmt = NumberFormat('#,##0.00', 'es_PE');

  /// Convierte un double al texto que va en el campo de texto.
  /// Si es null o 0, devuelve ''.
  static String fmtDouble(double? v) =>
      (v == null || v == 0) ? '' : v.toStringAsFixed(2);

  /// Parsea el texto de un campo numérico. Devuelve 0 si no es válido.
  static double parseTexto(String text) => double.tryParse(text) ?? 0;

  /// Calcula el costo final: (precioBase × cantidad) − descuento.
  static double calcCostoFinal({
    required double precioBase,
    required double cantidad,
    required double descuento,
  }) => (precioBase * cantidad) - descuento;

  /// Formatea un double con símbolo de moneda para mostrar en campos read-only.
  static String formatMoneda(String simbolo, double valor) =>
      '$simbolo ${_fmt.format(valor)}';
}
