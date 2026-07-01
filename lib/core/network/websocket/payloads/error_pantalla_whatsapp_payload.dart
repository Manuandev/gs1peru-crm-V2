// lib/core/network/websocket/payloads/error_pantalla_whatsapp_payload.dart

import 'package:app_crm/core/index_core.dart';

/// Payload parseado de la trama ERROR_PANTALLA_WHATSAPP.
///
/// Formato del servidor:
/// ERROR_PANTALLA_WHATSAPP±{codAsesor}¦{idChatCab}
///
/// Se recibe cuando el servidor falla al procesar un envío (texto, audio,
/// documento, etc.). No trae ID de mensaje ni idTokenMeta — el envío falló
/// antes de que el servidor pudiera confirmarlo, así que no hay forma de
/// saber cuál mensaje fue: se asume el más antiguo aún en estado 'wait'
/// para ese idChatCab.
class ErrorPantallaWhatsAppPayload {
  final String codAsesor;  // [0] Código del asesor
  final int idChatCab;     // [1] ID cabecera del chat

  const ErrorPantallaWhatsAppPayload({
    required this.codAsesor,
    required this.idChatCab,
  });

  /// Parsea el primer record de un WebSocketMessage tipo ERROR_PANTALLA_WHATSAPP
  static ErrorPantallaWhatsAppPayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;

    if (f.length < 2) return null;

    return ErrorPantallaWhatsAppPayload(
      codAsesor: f[0].trim(),
      idChatCab: int.tryParse(f[1].trim()) ?? 0,
    );
  }
}
