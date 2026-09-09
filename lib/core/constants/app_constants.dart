// lib/core/constants/app_constants.dart

import 'package:app_crm/config/index_config.dart';

/// Constantes usadas en el proyecto
///
/// PROPÓSITO:
/// - Llamar mas facil y rapido a constantes globales
/// - No harcodear ninguna direccion, asi es mas controlado
///
class AppConstants {
  AppConstants._();

  // Delegado a EnvConfig — la versión ahora depende de EnvConfig.current,
  // igual que baseUrl/urlArchivos, para no tener que sincronizarla a mano
  // por separado antes de cada build (ver EnvConfig.version).
  static String get version => EnvConfig.version;
  static const nombreApp = 'GS1 CRM';

  // Separador para serialización de sesión en cadena
  // Usa un carácter que NUNCA aparecerá en los datos
  static const String sepRegistros = '¬';
  static const String sepCampos = '¦';
  static const String sepListas = '¯';
  static const String sepComodin = '¨';
  static const String sepComodin2 = '±';
  static const String sepComodin3 = '¶';

  // Límites de caracteres en ChatTile (nombre/número ya no se recortan —
  // se muestran completos, ver chat_tile.dart)
  static const int maxCharsLineaMensaje = 25;
  static const int maxCharsMensajeChat = 50;
}
