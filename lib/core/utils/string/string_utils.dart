// lib\core\utils\string\string_utils.dart

class StringUtils {
  StringUtils._();

  static String convertStringToHex(String input) {
    return input.codeUnits
        .map((c) => c.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'El email es requerido';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) return 'Ingresa un email válido';
    return null;
  }
}
