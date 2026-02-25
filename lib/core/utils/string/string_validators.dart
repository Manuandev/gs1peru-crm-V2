/// Validador de email por defecto.
///
/// Verifica:
/// 1. Que no esté vacío
/// 2. Que tenga formato válido: usuario@dominio.ext
String? defaultValidator(String? value) {
  if (value == null || value.trim().isEmpty) return 'El email es requerido';
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  if (!emailRegex.hasMatch(value.trim())) return 'Ingresa un email válido';
  return null;
}
