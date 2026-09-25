// lib/core/network/websocket/payloads/unidad_trama.dart

import 'package:app_crm/core/index_core.dart';

/// Relación entre la unidad de negocio de una trama y la unidad activa.
enum AlcanceUnidad {
  /// Es de la unidad activa (o la trama no trae unidad todavía) → se pinta y
  /// se notifica como siempre.
  activa,

  /// Es de otra unidad asignada al asesor → NO se pinta en listas ni
  /// contadores, pero SÍ se notifica (con el nombre de la unidad).
  otraPropia,

  /// Es de una unidad que el asesor no tiene → se ignora por completo.
  ajena,
}

/// Unidad de negocio que viaja al final de las tramas de SignalR/FCM
/// (`idUnidad ¦ nombreUnidad`, ver notifications/CLAUDE.md). Cada proceso la
/// trae en una posición fija, justo después de sus campos actuales, para no
/// correr ningún índice existente.
class UnidadTrama {
  final int idUnidad;
  final String nombreUnidad;

  const UnidadTrama({required this.idUnidad, required this.nombreUnidad});

  /// Índice del campo `idUnidad` en el primer registro de cada proceso
  /// (`nombreUnidad` va en el siguiente). Único lugar a tocar si el backend
  /// cambia la posición.
  static const Map<String, int> _indiceIdUnidad = {
    // mensaje¦codAsesor¦idNumero¦tipo¦idChatCab¦idMensaje¦fecha¦nomArchivo¦
    // flgCerrado¦flgNuevaFecha¦telefono → [11] idUnidad ¦ [12] nombreUnidad
    'MENSAJE_WHATSAPP': 11,
    // idLead¦codAsesor¦nombreCliente¦numero¦idChatCab¦idNumero¦idContacto
    // → [7] idUnidad ¦ [8] nombreUnidad
    'NUEVO_LEAD_BOT': 7,
    // idLead¦nombre¦empresa¦…¦[11] canal → [12] idUnidad ¦ [13] nombreUnidad
    'NUEVO_LEAD': 12,
  };

  /// Unidad de la trama, o `null` si el proceso no la lleva o el backend
  /// todavía no la manda (idUnidad vacío/0).
  static UnidadTrama? deMensaje(WebSocketMessage message) {
    final indice = _indiceIdUnidad[message.process];
    if (indice == null || message.records.isEmpty) return null;
    final f = message.records.first;
    final idUnidad = f.length > indice ? int.tryParse(f[indice].trim()) : null;
    if (idUnidad == null || idUnidad == 0) return null;
    final nombre = f.length > indice + 1 ? f[indice + 1].trim() : '';
    return UnidadTrama(idUnidad: idUnidad, nombreUnidad: nombre);
  }

  /// Alcance de la trama respecto a la sesión en memoria. Sin unidad en la
  /// trama → [AlcanceUnidad.activa] (comportamiento de siempre, para no
  /// perder avisos mientras el backend no la mande).
  ///
  /// Solo sirve con la app viva (SessionService poblado) — en el isolate de
  /// FCM con la app cerrada el filtro por destinatario lo hace el backend.
  static AlcanceUnidad alcance(WebSocketMessage message) {
    final unidad = deMensaje(message);
    if (unidad == null) return AlcanceUnidad.activa;
    final session = SessionService();
    if (!session.unidades.contains(unidad.idUnidad)) return AlcanceUnidad.ajena;
    return unidad.idUnidad == session.idUnidadActiva
        ? AlcanceUnidad.activa
        : AlcanceUnidad.otraPropia;
  }
}
