// lib/core/utils/string/parse_utils.dart
// utils/parse_utils.dart

class ParseUtils {
  static List<String> campos(String raw, String separador) =>
      raw.split(separador).map((e) => e.trim()).toList();

  static String str(List<String> campos, int i) =>
      i < campos.length ? campos[i].trim() : '';

  static int toInt(List<String> campos, int i) =>
      int.tryParse(str(campos, i)) ?? 0;

  static double toDouble(List<String> campos, int i) =>
      double.tryParse(str(campos, i)) ?? 0.0;
}