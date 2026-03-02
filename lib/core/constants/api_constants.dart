// lib\core\constants\api_constants.dart

import 'package:app_crm/config/env/env_config.dart';

class ApiConstants {
  // Base URLs
  static String get baseUrl => EnvConfig.baseUrl;
  static String get urlArchivos => EnvConfig.urlArchivos;
  static String get urlWebSocket => EnvConfig.urlWebSocket;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========== SEGURIDAD ==========
  static const String login = 'Seguridad/ValidarLoginAppCRM';
  static const String loginGoogle = 'Seguridad/ValidarLoginGoogleAppCRM';

  // ========== LEADS ==========
  static const String lstleads = 'Lead/SPLeadLSTApp';

  // ========== RECORDATORIOS ==========
  static const String lstRecordatorios = 'Recordatorio/SPRecordatorioLSTApp';

  // ========== WHATSAPP ==========
  static const String lstChats = 'Wsp/SPWhatsappLSTApp';
  static const String listarChats = 'Wsp/ObtenerChats';
  static const String detalleChat = 'Wsp/ObtenerMensajes';
  static const String actualizarFavorito = 'Wsp/ActualizarFavorito';
  static const String enviarMensaje = 'Wsp/SendMessageWhatsApp';
  static const String guardarMultimedia = 'Wsp/GuardarMultimediaWhatsApp';

  // ========== HELPERS ==========

  // URLs completas (helpers)
  static String get urlLogin => '$baseUrl$login';
  static String get urlLoginGoogle => '$baseUrl$loginGoogle';
  static String get urlLeadsLst => '$baseUrl$lstleads';
  static String get urlRecordatoriosLst => '$baseUrl$lstRecordatorios';
  static String get urlChatsLst => '$baseUrl$lstChats';

  static String get urlListarChats => '$baseUrl$listarChats';
  static String get urlDetalleChat => '$baseUrl$detalleChat';
  static String get urlActualizarFavorito => '$baseUrl$actualizarFavorito';
  static String get urlEnviarMensaje => '$baseUrl$enviarMensaje';
  static String get urlGuardarMultimedia => '$baseUrl$guardarMultimedia';
}
