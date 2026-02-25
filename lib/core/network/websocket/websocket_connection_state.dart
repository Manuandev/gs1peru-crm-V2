/// Estados posibles de la conexión WebSocket / SignalR
enum WebSocketConnectionState {
  /// Conectado y listo para recibir/enviar mensajes
  connected,

  /// Desconectado (puede intentar reconectar)
  disconnected,

  /// En proceso de conexión inicial
  connecting,

  /// En proceso de reconexión automática
  reconnecting,

  /// Desconectado manualmente por el usuario o por logout
  /// No intentará reconectar automáticamente
  manuallyClosed,

  /// Sin internet — espera a recuperar conectividad
  noInternet,
}
