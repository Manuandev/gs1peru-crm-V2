// lib/core/network/websocket/payloads/nuevo_lead_bot_payload.dart

import 'package:app_crm/core/index_core.dart';

/// Payload parseado de la trama NUEVO_LEAD_BOT.
///
/// Formato del servidor:
/// NUEVO_LEAD_BOT±{idLead}¦{codAsesor}¦{nombreCliente}¦{numero}¦{idChatCab}
///
/// Esta trama se recibe cuando el bot crea un lead nuevo — la conversación
/// puede no existir todavía en la lista del asesor.
class NuevoLeadBotPayload {
  final int idLead;             // [0] ID del lead creado por el bot
  final String codAsesor;       // [1] Código del asesor asignado
  final String nombreCliente;   // [2] Nombre del cliente
  final String numero;          // [3] Número de teléfono del contacto
  final int idChatCab;          // [4] ID cabecera del chat

  const NuevoLeadBotPayload({
    required this.idLead,
    required this.codAsesor,
    required this.nombreCliente,
    required this.numero,
    required this.idChatCab,
  });

  /// Parsea el primer record de un WebSocketMessage tipo NUEVO_LEAD_BOT
  static NuevoLeadBotPayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;

    // Requerimos al menos hasta el índice 4 (idChatCab)
    if (f.length < 5) return null;

    return NuevoLeadBotPayload(
      idLead: int.tryParse(f[0].trim()) ?? 0,
      codAsesor: f[1].trim(),
      nombreCliente: f[2].trim(),
      numero: f[3].trim(),
      idChatCab: int.tryParse(f[4].trim()) ?? 0,
    );
  }
}
