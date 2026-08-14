// lib/core/utils/number/number_format_utils.dart

import 'package:app_crm/index_dependencies.dart';

/// Funciones puras de parseo y formato para campos numéricos de formularios
/// (precios, descuentos, cantidades). Reutilizable en cualquier feature —
/// no hardcodear NumberFormat ni lógica de parseo suelta en un widget.
class NumberFormatUtils {
  NumberFormatUtils._();

  static final _moneyFmt = NumberFormat('#,##0.00', 'es_PE');

  /// Texto para un campo decimal (precios, descuentos).
  /// Si es null o 0, devuelve ''.
  static String fmtDecimal(double? v) =>
      (v == null || v == 0) ? '' : v.toStringAsFixed(2);

  /// Texto para un campo entero (cantidades, participantes).
  /// Si es null o 0, devuelve ''.
  static String fmtInt(int? v) => (v == null || v == 0) ? '' : v.toString();

  /// Parsea el texto de un campo decimal. Devuelve 0 si no es válido.
  static double parseDecimal(String text) => double.tryParse(text) ?? 0;

  /// Parsea el texto de un campo entero. Devuelve 0 si no es válido.
  static int parseInt(String text) => int.tryParse(text) ?? 0;

  /// Formatea un valor con símbolo de moneda: "S/ 1,234.50"
  static String formatMoneda(String simbolo, double valor) =>
      '$simbolo ${_moneyFmt.format(valor)}';

  /// Solo el monto con separador de miles, sin símbolo: "1,234.50" — para
  /// componer manualmente cuando el símbolo debe ir pegado (sin espacio).
  static String formatMonto(double valor) => _moneyFmt.format(valor);
}
