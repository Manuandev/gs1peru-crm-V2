// lib/core/utils/string/parse_utils.dart
// utils/parse_utils.dart

class ParseUtils {
  static List<String> campos(String raw, String separador) =>
      raw.split(separador).map((e) => e.trim()).toList();

  static String str(List<String> campos, int i) =>
      i < campos.length ? campos[i].trim() : '';

  static String? strNullable(List<String> campos, int i) {
    if (i >= campos.length) return null;
    final v = campos[i].trim();
    return v.isEmpty ? null : v;
  }

  // Algunas columnas de tablas genéricas del backend (ej. SYSTABEXTER02,
  // reusada por varios catálogos con distinto significado por columna) son
  // DECIMAL/NUMERIC aunque el dato en sí sea un entero — el SP las manda
  // como texto con decimales ("8.000", "11.000"...). `int.tryParse` no
  // acepta un punto decimal y fallaba en silencio a `0` — bug real
  // encontrado en vivo el 2026-08-12 con `TipoDocumentoItem.
  // canCaracteresMax` (parte [10] del SP lstListas): el límite de N°
  // documento quedaba en 0 para TODO tipo de documento, sin que nada
  // avisara el error. Fallback a `double.tryParse(...).toInt()` — no
  // cambia el resultado para un entero plano ("8", primer intento ya
  // funciona), solo cubre el caso decimal. Trunca hacia 0 (`8.9` → `8`),
  // no redondea — asumido aceptable porque estos campos son conteos/ids,
  // nunca deberían traer una fracción real de por medio.
  static int toInt(List<String> campos, int i) {
    final s = str(campos, i);
    return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? 0;
  }

  static double toDouble(List<String> campos, int i) =>
      double.tryParse(str(campos, i)) ?? 0.0;

  static bool toBool(List<String> campos, int i) =>
      str(campos, i) == '1' || str(campos, i).toLowerCase() == 'true';

  /// Serializa un valor de salida (int?/double?) para el body de un SP —
  /// '' si es null o 0, para que el SP lo trate como NULL vía NULLIF/TRY_CAST.
  static String orEmpty(dynamic val) =>
      (val == null || val == 0) ? '' : val.toString();

  // Si es NAC es nacional | Si es INT es internacional
  static bool toBoolNAC(List<String> campos, int i) =>
      str(campos, i).toUpperCase() == 'NAC';

  // Si es NAC es nacional | Si es INT es internacional
  static bool toBoolINT(List<String> campos, int i) =>
      str(campos, i).toUpperCase() == 'INT';
}
