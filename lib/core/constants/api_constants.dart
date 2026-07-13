// lib/core/constants/api_constants.dart

import 'package:app_crm/config/index_config.dart';

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
  static const String loginGoogle = 'Seguridad/ValidarLoginGoogleApp';
  static const String recuperarUsuario = 'Seguridad/RecuperarUsuario';

  // ========== LISTAS ==========
  static const String lstListas = 'Listas/SPListasLSTApp';

  // ========== HOME ==========
  static const String lstHome = 'Home/SPHomeLSTApp';
  static const String cudHome = 'Home/SPHomeCUDApp';

  // ========== LEADS ==========
  static const String lstleads = 'Lead/SPLeadLSTApp';
  static const String cudleads = 'Lead/SPLeadCUDApp';

  // ========== RECORDATORIOS ==========
  static const String lstRecordatorios = 'Recordatorio/SPRecordatorioLSTApp';

  // ========== WHATSAPP ==========
  static const String lstChats = 'Wsp/SPWhatsappLSTApp';
  static const String listarChats = 'Wsp/ObtenerChats';
  static const String detalleChat = 'Wsp/ObtenerMensajes';
  static const String actualizarFavorito = 'Wsp/ActualizarFavorito';
  static const String enviarMensaje = 'Wsp/SendMessageWhatsApp';
  static const String guardarMultimedia = 'Wsp/GuardarMultimediaWhatsApp';

  // ========== PROSPECTOS ==========
  static const String lstProspectos = 'Prospecto/SPProspectoLSTApp';
  static const String cudProspectos = 'Prospecto/SPProspectoCUDApp';

  // ========== PROPUESTA ==========
  static const String lstPropuestas = 'Propuesta/SPPropuestaLSTApp';
  static const String cudPropuestas = 'Propuesta/SPPropuestaCUDApp';

  // ========== SOLICITUD ==========
  static const String lstSolicitudes = 'Solicitud/SPSolicitudLSTApp';
  static const String cudSolicitudes = 'Solicitud/SPSolicitudCUDApp';
  static const String cudSolicitudesArchivos = 'Solicitud/SPSolicitudCUDAppArchivos';

  // ========== COBRANZAS ==========
  static const String lstCobranzas = 'Cobranza/SPCobranzaLSTApp';
  static const String cudCobranzas = 'Cobranza/SPCobranzaCUDApp';

  // ========== CLIENTES ==========
  // Autocompletado por DNI/RUC — interno primero, RENIEC/SUNAT de fallback.
  static const String buscarDocumento = 'Clientes/BuscarDocumento';

  // ========== HELPERS ==========

  // URLs completas (helpers)
  static String get urlLogin => '$baseUrl$login';
  static String get urlLoginGoogle => '$baseUrl$loginGoogle';
  static String get urlRecuperarUsuario => '$baseUrl$recuperarUsuario';

  // ========== LISTAS ==========
  static String get urlListasLst => '$baseUrl$lstListas';

  // ========== HOME ==========
  static String get urlHomeLst => '$baseUrl$lstHome';
  static String get urlHomeCud => '$baseUrl$cudHome';

  // ========== LEADS ==========
  static String get urlLeadsLst => '$baseUrl$lstleads';
  static String get urlLeadsCud => '$baseUrl$cudleads';

  // ========== RECORDATORIOS ==========
  static String get urlRecordatoriosLst => '$baseUrl$lstRecordatorios';

  // ========== WHATSAPP ==========
  static String get urlChatsLst => '$baseUrl$lstChats';
  static String get urlListarChats => '$baseUrl$listarChats';
  static String get urlDetalleChat => '$baseUrl$detalleChat';
  static String get urlActualizarFavorito => '$baseUrl$actualizarFavorito';
  static String get urlEnviarMensaje => '$baseUrl$enviarMensaje';
  static String get urlGuardarMultimedia => '$baseUrl$guardarMultimedia';

  // ========== PROSPECTOS ==========
  static String get urlProspectosLst => '$baseUrl$lstProspectos';
  static String get urlProspectosCud => '$baseUrl$cudProspectos';

  // ========== PROPUESTA ==========
  static String get urlPropuestasLst => '$baseUrl$lstPropuestas';
  static String get urlPropuestasCud => '$baseUrl$cudPropuestas';

  // ========== SOLICITUD ==========
  static String get urlSolicitudesLst => '$baseUrl$lstSolicitudes';
  static String get urlSolicitudesCud => '$baseUrl$cudSolicitudes';
  static String get urlSolicitudesCudArchivos => '$baseUrl$cudSolicitudesArchivos';

  // ========== COBRANZAS ==========
  static String get urlCobranzasLst => '$baseUrl$lstCobranzas';
  static String get urlCobranzasCud => '$baseUrl$cudCobranzas';

  // ========== CLIENTES ==========
  static String get urlBuscarDocumento => '$baseUrl$buscarDocumento';
}
