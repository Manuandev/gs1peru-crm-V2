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
  // Separa los sub-campos de PARTIDAM/PARTIDAO (SYSTABEXTER02) dentro de un
  // mismo campo — ej. tipo de documento "8|N|0|1|1|0|1" (ver TipoDocumentoItem).
  static const String sepPartida = '|';

  // Límites de caracteres en ChatTile (nombre/número ya no se recortan —
  // se muestran completos, ver chat_tile.dart)
  static const int maxCharsLineaMensaje = 25;
  static const int maxCharsMensajeChat = 50;

  // Búsqueda libre en listas paginadas (el filtro lo aplica el SP): espera
  // tras la última tecla antes de consultar, y mínimo de caracteres para que
  // filtre (con 1-2 letras traería media base y no aporta).
  static const Duration debounceBusqueda = Duration(milliseconds: 500);
  static const int busquedaMinCaracteres = 3;

  // Wizard de solicitudes: ignora un segundo "Continuar/Siguiente" dentro de
  // este tiempo tras cambiar de paso — el botón del paso siguiente queda en
  // la misma posición y un doble toque saltaba 2 → 3 → 4 (2026-09-14).
  static const Duration bloqueoDobleToquePaso = Duration(milliseconds: 600);

  // Chat: segundos que un mensaje enviado queda retenido con el botón
  // "Deshacer" antes de salir de verdad por el socket (la API de WhatsApp no
  // permite borrar un mensaje ya enviado). Default si la config TDE/2 no carga
  // — ver ConfiguracionService.segundosDeshacerMensaje.
  static const int segundosDeshacerMensajeDefecto = 3;
}
