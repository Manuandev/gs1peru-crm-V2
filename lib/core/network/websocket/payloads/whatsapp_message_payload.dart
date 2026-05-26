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
  final String nomArchivo;

  const WhatsAppMessagePayload({
    required this.mensaje,
    required this.asesor,
    required this.leadId,
    required this.tipoMensaje,
    required this.idInterno,
    required this.whatsappMsgId,
    required this.fecha,
    required this.telefono,
    this.nomArchivo = '',
  });

  /// Parsea el primer record de un WebSocketMessage tipo MENSAJE_WHATSAPP
  static WhatsAppMessagePayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    
    // Requerimos al menos hasta el índice 6 (fecha)
    if (f.length < 7) return null;

    return WhatsAppMessagePayload(
      mensaje: f[0].trim(),
      asesor: f.length > 1 ? f[1].trim() : '',
      leadId: f.length > 2 ? (int.tryParse(f[2].trim()) ?? 0) : 0,
      tipoMensaje: f.length > 3 ? f[3].trim() : '',
      idInterno: f.length > 4 ? (int.tryParse(f[4].trim()) ?? 0) : 0,
      whatsappMsgId: f.length > 5 ? f[5].trim() : '',
      fecha: f.length > 6 ? f[6].trim() : '',
      nomArchivo: f.length > 7 ? f[7].trim() : '',
      telefono: f.length > 10 ? f[10].trim() : '',
    );
  }
}
