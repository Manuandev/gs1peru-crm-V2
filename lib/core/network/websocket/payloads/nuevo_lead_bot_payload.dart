// lib/core/network/websocket/payloads/nuevo_lead_bot_payload.dart

import 'package:app_crm/core/index_core.dart';

/// Payload parseado de la trama NUEVO_LEAD_BOT.
///
/// Formato del servidor:
/// NUEVO_LEAD_BOT±{idLead}¦{codAsesor}¦{nombreCliente}¦{numero}¦{idChatCab}¦{idNumero}¦{idContacto}
///
/// Esta trama se recibe cuando el bot crea un lead nuevo — la conversación
/// puede no existir todavía en la lista del asesor.
class NuevoLeadBotPayload {
  final int idLead;             // [0] ID del lead creado por el bot
  final String codAsesor;       // [1] Código del asesor asignado
  final String nombreCliente;   // [2] Nombre del cliente
  final String numero;          // [3] Número de teléfono del contacto
  final int idChatCab;          // [4] ID cabecera del chat
  final int idNumero;           // [5] ID numero
  // [6] ID contacto — agregado 2026-08-20 para que "Ver negociación" pueda
  // navegar a AppRoutes.detalleContacto (exige idContacto, no idNumero, ver
  // lead/CLAUDE.md → "Migración de ancla ID_NUMERO → ID_CONTACTO"). Default
  // 0 (no bloqueante) por si algún build todavía no tiene el campo nuevo del
  // backend — en ese caso "Ver negociación" queda sin destino, no revienta.
  final int idContacto;

  const NuevoLeadBotPayload({
    required this.idLead,
    required this.codAsesor,
    required this.nombreCliente,
    required this.numero,
    required this.idChatCab,
    required this.idNumero,
    this.idContacto = 0,
  });

  /// Parsea el primer record de un WebSocketMessage tipo NUEVO_LEAD_BOT
  static NuevoLeadBotPayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;

    // Requerimos al menos hasta el índice 5 (idNumero) — idContacto [6] es
    // opcional, no bloquea el parseo si el backend todavía no lo manda.
    if (f.length < 6) return null;

    return NuevoLeadBotPayload(
      idLead: int.tryParse(f[0].trim()) ?? 0,
      codAsesor: f[1].trim(),
      nombreCliente: f[2].trim(),
      numero: f[3].trim(),
      idChatCab: int.tryParse(f[4].trim()) ?? 0,
      idNumero: int.tryParse(f[5].trim()) ?? 0,
      idContacto: f.length > 6 ? (int.tryParse(f[6].trim()) ?? 0) : 0,
    );
  }
}
