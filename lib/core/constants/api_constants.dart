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
  static const String login = 'Seguridad/ValidarLoginApp';
  static const String loginGoogle = 'Seguridad/ValidarLogin';

  // ========== LEADS ==========
  // static const String leads = 'Leads/ListarLeads';
  // static const String recordatorios = 'Leads/ListarRecordatorios';
  // static const String detalleLeads = 'Leads/TraerLead';
  static const String leads = 'Lead/SPLead';
  static const String recordatorios = 'Recordatorio/SPRecordatorio';
  

  // ========== WHATSAPP ==========
  static const String listarChats = 'Wsp/ObtenerChats';
  static const String detalleChat = 'Wsp/ObtenerMensajes';
  static const String actualizarFavorito = 'Wsp/ActualizarFavorito';
  static const String enviarMensaje = 'Wsp/SendMessageWhatsApp';
  static const String guardarMultimedia = 'Wsp/GuardarMultimediaWhatsApp';

  // ========== HELPERS ==========

  // URLs completas (helpers)
  static String get urlLogin => '$baseUrl$login';
  static String get urlLoginGoogle => '$baseUrl$loginGoogle';
  static String get urlLeads => '$baseUrl$leads';
  static String get urlRecordatorios => '$baseUrl$recordatorios';

  static String get urlListarChats => '$baseUrl$listarChats';
  static String get urlDetalleChat => '$baseUrl$detalleChat';
  static String get urlActualizarFavorito => '$baseUrl$actualizarFavorito';
  static String get urlEnviarMensaje => '$baseUrl$enviarMensaje';
  static String get urlGuardarMultimedia => '$baseUrl$guardarMultimedia';
}
