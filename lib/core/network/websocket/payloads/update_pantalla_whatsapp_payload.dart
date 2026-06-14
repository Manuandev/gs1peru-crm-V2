// lib/core/network/websocket/payloads/update_pantalla_whatsapp_payload.dart

import 'package:app_crm/core/index_core.dart';

/// Payload parseado de la trama UPDATE_PANTALLA_WHATSAPP.
///
/// Formato del servidor:
/// UPDATE_PANTALLA_WHATSAPP±{msg}¦{codAsesor}¦{idLead}¦{tipoMensaje}¦{idChatCab}¦{idMensaje}¦{hora}¦{nombreArchivo}¦{telefono}
///
/// Esta trama se recibe como confirmación de un mensaje que **el asesor** envió.
/// El servidor responde con los datos del mensaje ya registrado.
class UpdatePantallaWhatsAppPayload {
  final String mensaje;         // [0] Contenido del mensaje enviado
  final String codAsesor;       // [1] Código del asesor que envió
  final int leadId;             // [2] ID del lead
  final String tipoMensaje;     // [3] text, image, video, audio, document
  final String idChatCab;       // [4] ID cabecera del chat
  final String idMensaje;       // [5] ID único del mensaje (WhatsApp msg ID)
  final String hora;            // [6] Hora del envío
  final String nomArchivo;      // [7] Nombre del archivo adjunto
  final String telefono;        // [8] Número de teléfono

  const UpdatePantallaWhatsAppPayload({
    required this.mensaje,
    required this.codAsesor,
    required this.leadId,
    required this.tipoMensaje,
    required this.idChatCab,
    required this.idMensaje,
    required this.hora,
    this.nomArchivo = '',
    this.telefono = '',
  });

  /// Parsea el primer record de un WebSocketMessage tipo UPDATE_PANTALLA_WHATSAPP
  static UpdatePantallaWhatsAppPayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;

    // Requerimos al menos hasta el índice 5 (idMensaje)
    if (f.length < 6) return null;

    return UpdatePantallaWhatsAppPayload(
      mensaje: f[0].trim(),
      codAsesor: f.length > 1 ? f[1].trim() : '',
      leadId: f.length > 2 ? (int.tryParse(f[2].trim()) ?? 0) : 0,
      tipoMensaje: f.length > 3 ? f[3].trim() : '',
      idChatCab: f.length > 4 ? f[4].trim() : '',
      idMensaje: f.length > 5 ? f[5].trim() : '',
      hora: f.length > 6 ? f[6].trim() : '',
      nomArchivo: f.length > 7 ? f[7].trim() : '',
      telefono: f.length > 8 ? f[8].trim() : '',
    );
  }
}
