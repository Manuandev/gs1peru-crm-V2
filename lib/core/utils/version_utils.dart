// lib/core/utils/version_utils.dart
//
// Compara versiones "X.Y.Z" (semver simple, sin sufijos) — usado para saber
// si AppConstants.version quedó atrás respecto a la que devuelve
// ApiConstants.urlVersionCheck. Ver AppUpdateService.

class VersionUtils {
  VersionUtils._();

  /// true si [actual] es una versión anterior a [remota].
  static bool esMenor(String actual, String remota) {
    final a = _partes(actual);
    final b = _partes(remota);
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return a[i] < b[i];
    }
    return false;
  }

  static List<int> _partes(String version) {
    final partes = version
        .split('.')
        .map((p) => int.tryParse(p.trim()) ?? 0)
        .toList();
    while (partes.length < 3) {
      partes.add(0);
    }
    return partes;
  }
}
