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


  // ========== NOTIFICACIONES ==========
  static const String lstNotificaciones = 'Notificaciones/SPNotificacionesLSTApp';
  static const String cudNotificaciones = 'Notificaciones/SPNotificacionesCUDApp';

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

  // ========== PLANTILLAS (WhatsApp) ==========
  static const String lstPlantillas = 'Wsp/SPPlantillaLSTApp';
  static const String cudPlantillas = 'Wsp/SPPlantillaCUDApp';
  static const String guardarMultimediaPlantilla = 'Wsp/GuardarMultimediaPlantilla';

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

  // ========== GENERIC ==========
  // Descarga de plantillas Excel (ej. carga masiva de participantes) — lee
  // del mismo FileServer\PLANTILLAS\<subcarpeta> que usa GS1Peru.AppWeb.
  static const String descargarPlantilla = 'Generic/DescargarArchivoPlantilla';

  // ========== CONTACTO ==========
  // SPs reales confirmados (2026-07-23): CRM.CSV_CONTACTO_LST_APP (task 'D')
  // y CRM.CSV_CONTACTO_CUD_APP (task 'U', solo rama CREATE) — ver
  // lead_remote_datasource.dart y lead/CLAUDE.md. ⚠️ Los nombres de ruta de
  // acá (segmento del controller C#) siguen siendo un placeholder — ajustar
  // cuando se confirme el nombre real del controller/acción.
  static const String lstContacto = 'Contacto/SPContactoLSTApp';
  static const String cudContacto = 'Contacto/SPContactoCUDApp';

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

  // ========== NOTIFICACIONES ==========
  static String get urlNotificacionesLst => '$baseUrl$lstNotificaciones';
  static String get urlNotificacionesCud => '$baseUrl$cudNotificaciones';

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

  // ========== PLANTILLAS (WhatsApp) ==========
  static String get urlPlantillasLst => '$baseUrl$lstPlantillas';
  static String get urlPlantillasCud => '$baseUrl$cudPlantillas';
  static String get urlGuardarMultimediaPlantilla =>
      '$baseUrl$guardarMultimediaPlantilla';

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

  // ========== GENERIC ==========
  static String get urlDescargarPlantilla => '$baseUrl$descargarPlantilla';

  // ========== CONTACTO ==========
  static String get urlContactoLst => '$baseUrl$lstContacto';
  static String get urlContactoCud => '$baseUrl$cudContacto';
}
