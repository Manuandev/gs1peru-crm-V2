/// Representa un mensaje ya parseado recibido por el WebSocket.
///
/// El protocolo del servidor usa el formato:
///   PROCESO¯registro1¬registro2¬...
///
/// Cada registro usa ¦ como separador de campos.
class WebSocketMessage {
  /// Identificador del proceso al que pertenece este mensaje.
  /// Ejemplos: "BOLETO", "LEAD", "NOTIFICACION"
  final String process;

  /// Lista de registros parseados. Cada registro es una lista de campos.
  /// Ejemplo: [["campo1", "campo2"], ["campo1", "campo2"]]
  final List<List<String>> records;

  /// Timestamp de cuando se recibió el mensaje
  final DateTime receivedAt;

  const WebSocketMessage({
    required this.process,
    required this.records,
    required this.receivedAt,
  });

  /// Shortcut para obtener el primer registro (caso más común)
  List<String>? get firstRecord => records.isNotEmpty ? records.first : null;

  /// Indica si el mensaje llegó vacío (sin registros válidos)
  bool get isEmpty => records.isEmpty;

  @override
  String toString() =>
      'WebSocketMessage(process: $process, records: ${records.length})';
}
