import 'dart:async';
import 'websocket_connection_state.dart';
import 'websocket_message.dart';

/// Contrato del servicio de WebSocket / SignalR.
///
/// Cualquier implementación (real, mock para tests) debe cumplir esta interfaz.
/// Esto permite inyectar dependencias fácilmente y testear sin conexión real.
abstract class ISignalRService {
  // ─── Streams públicos ────────────────────────────────────────────────────

  /// Stream del estado de conexión actual.
  /// Emite cada vez que el estado cambia.
  Stream<WebSocketConnectionState> get connectionStateStream;

  /// Stream de TODOS los mensajes recibidos, ya parseados.
  ///
  /// Cada feature se suscribe y filtra por [WebSocketMessage.process]:
  /// ```dart
  /// signalRService.messageStream
  ///   .where((msg) => msg.process == 'LEAD')
  ///   .listen((msg) { ... });
  /// ```
  Stream<WebSocketMessage> get messageStream;

  // ─── Estado actual ────────────────────────────────────────────────────────

  /// Estado de conexión actual (sin necesidad de suscribirse al stream)
  WebSocketConnectionState get currentState;

  /// Indica si en este momento hay conexión activa con el hub
  bool get isConnected;

  // ─── Ciclo de vida ────────────────────────────────────────────────────────

  /// Inicia la conexión con el hub SignalR.
  /// Si ya está conectado o conectando, no hace nada.
  Future<void> connect();

  /// Fuerza una reconexión aunque esté en proceso.
  /// Útil al recuperar internet o al volver de background.
  Future<void> forceReconnect();

  /// Reconecta luego de haber llamado [close] manualmente.
  Future<void> reconnect();

  /// Cierra la conexión limpiamente.
  /// No intentará reconectar hasta llamar [reconnect] o [forceReconnect].
  Future<void> close();

  /// Resetea el servicio a su estado inicial sin cerrar streams.
  /// Útil al hacer logout.
  Future<void> reset();

  /// Libera todos los recursos (streams incluidos).
  /// Llamar solo al destruir la app o en tests.
  Future<void> dispose();

  // ─── Envío de mensajes ────────────────────────────────────────────────────

  /// Envía un mensaje al hub SignalR.
  /// Retorna `true` si se envió correctamente, `false` si no hay conexión.
  bool sendMessage(String message);
}
