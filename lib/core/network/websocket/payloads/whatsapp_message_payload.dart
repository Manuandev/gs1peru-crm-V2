// lib/core/network/websocket/payloads/whatsapp_message_payload.dart

import 'package:app_crm/core/index_core.dart';

/// Payload parseado de la trama MENSAJE_WHATSAPP.
///
/// Formato del servidor:
/// MENSAJE_WHATSAPP±{msg}¦{codAsesor}¦{idLead}¦{tipoMensaje}¦{idChatCab}¦{idMensaje}¦{fchEnvio} {horaEnvio}¦{nombreArchivo}¦{flgCerrado}¦{flgNuevaFecha}¦{telefono}
///
/// Esta trama se recibe cuando el **cliente** envía un mensaje al asesor.
class WhatsAppMessagePayload {
  final String mensaje;         // [0] Contenido del mensaje
  final String codAsesor;       // [1] Código del asesor asignado
  final int leadId;             // [2] ID del lead
  final String tipoMensaje;     // [3] text, image, video, audio, document
  final String idChatCab;       // [4] ID cabecera del chat
  final String idMensaje;       // [5] ID único del mensaje (WhatsApp msg ID)
  final String fecha;           // [6] Fecha y hora del envío
  final String nomArchivo;      // [7] Nombre del archivo adjunto
  final bool flgCerrado;        // [8] Flag si el chat está cerrado
  final bool flgNuevaFecha;     // [9] Flag si es nueva fecha (separador)
  final String telefono;        // [10] Número de teléfono

  const WhatsAppMessagePayload({
    required this.mensaje,
    required this.codAsesor,
    required this.leadId,
    required this.tipoMensaje,
    required this.idChatCab,
    required this.idMensaje,
    required this.fecha,
    required this.telefono,
    this.nomArchivo = '',
    this.flgCerrado = false,
    this.flgNuevaFecha = false,
  });

  /// Parsea el primer record de un WebSocketMessage tipo MENSAJE_WHATSAPP
  static WhatsAppMessagePayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;

    // Requerimos al menos hasta el índice 6 (fecha)
    if (f.length < 7) return null;

    return WhatsAppMessagePayload(
      mensaje: f[0].trim(),
      codAsesor: f.length > 1 ? f[1].trim() : '',
      leadId: f.length > 2 ? (int.tryParse(f[2].trim()) ?? 0) : 0,
      tipoMensaje: f.length > 3 ? f[3].trim() : '',
      idChatCab: f.length > 4 ? f[4].trim() : '',
      idMensaje: f.length > 5 ? f[5].trim() : '',
      fecha: f.length > 6 ? f[6].trim() : '',
      nomArchivo: f.length > 7 ? f[7].trim() : '',
      flgCerrado: f.length > 8 ? f[8].trim() == '1' : false,
      flgNuevaFecha: f.length > 9 ? f[9].trim() == '1' : false,
      telefono: f.length > 10 ? f[10].trim() : '',
    );
  }
}
