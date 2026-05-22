// lib/core/notifications/handlers/notification_handler.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/network/websocket/websocket_message.dart';
import 'package:app_crm/core/notifications/index_notifications.dart';

class NotificationHandler {
  NotificationHandler._();
  static final NotificationHandler instance = NotificationHandler._();

  void handle(WebSocketMessage message) {
    final notif = _parse(message);
    if (notif != null) NotificationService.instance.show(notif);
  }

  AppNotification? _parse(WebSocketMessage message) {
    return switch (message.process) {
      'MENSAJE_WHATSAPP' => _parseWhatsApp(message),
      'NUEVO_LEAD' => _parseLead(message),
      'RECORDATORIO' => _parseRecordatorio(message),
      _ => null,
    };
  }

  AppNotification? _parseWhatsApp(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    String g(int i) => i < f.length ? f[i].trim() : '';

    return AppNotification(
      title: 'Mensaje WhatsApp CRM', //g(0), // Prueba
      body: _bodyPorTipo(g(3), g(0)), // text → '💬 Nuevo mensaje...'
      route: AppRoutes.detalleChat,
      payload: {
        'idLead': g(2), // 106180
      },
    );
  }

  // En NotificationHandler — agrega los parsers que faltan
  AppNotification? _parseLead(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    String g(int i) => i < f.length ? f[i].trim() : '';

    return AppNotification(
      title: '🔔 Nuevo lead',
      body: g(0), // nombre del lead
      route: AppRoutes.leads,
      payload: {'idLead': g(1), 'nombre': g(0)},
    );
  }

  AppNotification? _parseRecordatorio(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    String g(int i) => i < f.length ? f[i].trim() : '';

    return AppNotification(
      title: '⏰ Recordatorio',
      body: g(0),
      route: AppRoutes.recordatorios,
      payload: {'idRecordatorio': g(1)},
    );
  }

  String _bodyPorTipo(String tipo, String mensaje) =>
      switch (tipo.toLowerCase()) {
        'image' => '📷 Imagen',
        'audio' => '🎵 Audio',
        'video' => '🎥 Video',
        'document' => '📄 Documento',
        _ => mensaje,
      };
}
