import 'package:flutter/material.dart';

import 'websocket_message.dart';

/// Responsable de parsear los mensajes crudos del servidor SignalR
/// al modelo [WebSocketMessage].
///
/// Protocolo del servidor:
///   PROCESO¯registro1¦campo2¬registro2¦campo2¬...
///
/// Separadores:
///   ¯  →  separa proceso de registros
///   ¬  →  separa registros entre sí
///   ¦  →  separa campos dentro de un registro
class WebSocketMessageParser {
  // Separadores del protocolo — centralizado aquí para fácil mantenimiento
  static const String _processSeparator = '±';
  static const String _recordSeparator = '¬';
  static const String _fieldSeparator = '¦';

  /// Parsea el mensaje crudo recibido del servidor.
  ///
  /// Retorna `null` si el mensaje no tiene el formato esperado.
  static WebSocketMessage? parse(dynamic rawMessage) {
    if (rawMessage == null) return null;

    final String raw = rawMessage
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim();

    final List<String> parts = raw.split(_processSeparator);
    if (parts.length < 2) {
      debugPrint('[PARSER] ⚠️ Sin separador ±: $raw');
      return null;
    }

    final String process = parts[0].trim().toUpperCase();
    final String rawRecords = parts[1];

    final List<List<String>> records = rawRecords
        .split(_recordSeparator)
        .where((r) => r.isNotEmpty)
        .map((r) => r.split(_fieldSeparator))
        .where((f) => f.isNotEmpty)
        .toList();

    debugPrint('[PARSER] proceso:$process | registros:$records');

    return WebSocketMessage(
      process: process,
      records: records,
      receivedAt: DateTime.now(),
    );
  }
}
