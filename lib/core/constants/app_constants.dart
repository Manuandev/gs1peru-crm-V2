// lib/core/constants/app_constants.dart

/// Constantes usadas en el proyecto
///
/// PROPÓSITO:
/// - Llamar mas facil y rapido a constantes globales
/// - No harcodear ninguna direccion, asi es mas controlado
///
class AppConstants {
  AppConstants._();

  static const version = '1.0.3';
  static const nombreApp = 'GS1 CRM';

  // Separador para serialización de sesión en cadena
  // Usa un carácter que NUNCA aparecerá en los datos
  static const String sepRegistros = '¬';
  static const String sepCampos = '¦';
  static const String sepListas = '¯';
  static const String sepComodin = '¨';
  static const String sepComodin2 = '±';
  static const String sepComodin3 = '¶';

  // Límites de caracteres en ChatTile
  static const int maxCharsNombreChat = 15;
  static const int maxCharsLineaMensaje = 25;
  static const int maxCharsMensajeChat = 50;
}
