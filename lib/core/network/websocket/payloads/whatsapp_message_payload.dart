// lib\core\network\websocket\payloads\whatsapp_message_payload.dart

import 'package:app_crm/core/index_core.dart';

class WhatsAppMessagePayload {
  final String mensaje;
  final String asesor;
  final int leadId;
  final String tipoMensaje;
  final int idInterno;
  final String whatsappMsgId;
  final String fecha;
  final String telefono;

  const WhatsAppMessagePayload({
    required this.mensaje,
    required this.asesor,
    required this.leadId,
    required this.tipoMensaje,
    required this.idInterno,
    required this.whatsappMsgId,
    required this.fecha,
    required this.telefono,
  });

  /// Parsea el primer record de un WebSocketMessage tipo MENSAJE_WHATSAPP
  static WhatsAppMessagePayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    if (f.length < 11) return null;

    return WhatsAppMessagePayload(
      mensaje: f[0].trim(),
      asesor: f[1].trim(),
      leadId: int.tryParse(f[2].trim()) ?? 0,
      tipoMensaje: f[3].trim(),
      idInterno: int.tryParse(f[4].trim()) ?? 0,
      whatsappMsgId: f[5].trim(),
      fecha: f[6].trim(),
      telefono: f[10].trim(),
    );
  }
}
