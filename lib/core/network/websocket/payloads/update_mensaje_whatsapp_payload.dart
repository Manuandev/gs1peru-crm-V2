// lib\core\network\websocket\payloads\update_mensaje_whatsapp_payload.dart

import 'package:app_crm/core/index_core.dart';

/// Payload parseado de la trama UPDATE_MENSAJE_WHATSAPP.
///
/// Formato del servidor:
/// UPDATE_MENSAJE_WHATSAPP±{idLead}¦{idMensaje}¦{codAsesor}¦{estado}¦{fchRegistro}¦{fchLectura}¦{telefono}
///
/// Esta trama se recibe cuando un mensaje cambia de estado:
///   wait → sent → delivered → read
class UpdateMensajeWhatsAppPayload {
  final int leadId;             // [0] ID del lead
  final String idMensaje;       // [1] ID del mensaje a actualizar
  final String codAsesor;       // [2] Código del asesor
  final String estado;          // [3] Nuevo estado: sent, delivered, read, failed
  final String fchRegistro;     // [4] Fecha de registro del estado
  final String fchLectura;      // [5] Fecha de lectura (si aplica)
  final String telefono;        // [6] Teléfono

  const UpdateMensajeWhatsAppPayload({
    required this.leadId,
    required this.idMensaje,
    required this.codAsesor,
    required this.estado,
    this.fchRegistro = '',
    this.fchLectura = '',
    this.telefono = '',
  });

  /// Parsea el primer record de un WebSocketMessage tipo UPDATE_MENSAJE_WHATSAPP
  static UpdateMensajeWhatsAppPayload? fromMessage(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;

    // Requerimos al menos hasta el índice 3 (estado)
    if (f.length < 4) return null;

    return UpdateMensajeWhatsAppPayload(
      leadId: int.tryParse(f[0].trim()) ?? 0,
      idMensaje: f.length > 1 ? f[1].trim() : '',
      codAsesor: f.length > 2 ? f[2].trim() : '',
      estado: f.length > 3 ? f[3].trim() : '',
      fchRegistro: f.length > 4 ? f[4].trim() : '',
      fchLectura: f.length > 5 ? f[5].trim() : '',
      telefono: f.length > 6 ? f[6].trim() : '',
    );
  }
}
