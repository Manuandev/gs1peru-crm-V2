// lib/core/utils/version_utils.dart
//
// Compara versiones "X.Y.Z" (semver simple, sin sufijos) — usado para saber
// si AppConstants.version quedó atrás respecto a la que devuelve
// ApiConstants.urlVersionCheck. Ver AppUpdateService.

class VersionUtils {
  VersionUtils._();

  /// true si [actual] es una versión anterior a [remota].
  /// Compara todos los segmentos que tenga la más larga de las dos (ej.
  /// '1.0.13' de 3 partes vs '1.0.0.1' de 4) — nunca ignora un segmento de
  /// más por diferencia de longitud entre ambas.
  static bool esMenor(String actual, String remota) {
    final a = _partes(actual);
    final b = _partes(remota);
    final largo = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < largo; i++) {
      final ai = i < a.length ? a[i] : 0;
      final bi = i < b.length ? b[i] : 0;
      if (ai != bi) return ai < bi;
    }
    return false;
  }

  static List<int> _partes(String version) {
    return version.split('.').map((p) => int.tryParse(p.trim()) ?? 0).toList();
  }
}
