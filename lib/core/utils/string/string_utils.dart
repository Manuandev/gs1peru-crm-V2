// lib/core/utils/string/string_utils.dart

extension StringExtensions on String {
  String get limpiarTelefono {
    final tienePlus = trimLeft().startsWith('+');
    final soloDigitos = replaceAll(RegExp(r'[^\d]'), '');
    return tienePlus ? '+$soloDigitos' : soloDigitos;
  }

  String get convertToHex {
    return codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join();
  }

  // Nombre de archivo seguro para la API de WhatsApp — solo letras sin tilde,
  // números, guion, guion bajo y punto. Acentos/eñe/símbolos (incluyendo un
  // acento "suelto" mal codificado, ej. "NUTRICIO´N") hacen que Meta rechace
  // el envío del documento en silencio aunque el archivo ya esté guardado.
  String get sanitizarNombreArchivo {
    return replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '');
  }
}

extension NullableStringExtensions on String? {
  String? get emailValidator {
    if (this == null || this!.trim().isEmpty) return 'El email es requerido';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(this!.trim())) return 'Ingresa un email válido';
    return null;
  }
}
