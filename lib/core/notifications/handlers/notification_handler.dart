// lib/core/notifications/handlers/notification_handler.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

class NotificationHandler {
  NotificationHandler._();
  static final NotificationHandler instance = NotificationHandler._();

  void show(WebSocketMessage message) {
    final notif = _parse(message);
    if (notif != null) NotificationService.instance.show(notif);
  }

  void handle(WebSocketMessage message) {
    final notif = _parse(message);
    if (notif == null) return;
    if (_isSuppressed(message)) return; // 👈 única línea nueva en handle()
    NotificationService.instance.show(notif);
  }

  bool _isSuppressed(WebSocketMessage message) {
    final String? route = AppRouteObserver.instance.currentRoute;

    return switch (message.process) {
      'MENSAJE_WHATSAPP' => _suppressWhatsApp(route, message),
      'NUEVO_LEAD' => route == AppRoutes.leads,
      _ => false,
    };
  }

  bool _suppressWhatsApp(String? route, WebSocketMessage message) {
    if (route == AppRoutes.chats) return true;

    if (route == AppRoutes.detalleChat) {
      final int? activeId = AppRouteObserver.instance.activeLeadId;
      final int? incomingId = _extractLeadId(message);
      return activeId != null && activeId == incomingId;
    }

    return false;
  }

  int? _extractLeadId(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    return f.length > 2 ? int.tryParse(f[2].trim()) : null;
  }

  AppNotification? _parse(WebSocketMessage message) {
    return switch (message.process) {
      'MENSAJE_WHATSAPP' => _parseWhatsApp(message),
      'NUEVO_LEAD' => _parseLead(message),
      _ => null,
    };
  }

  AppNotification? _parseWhatsApp(WebSocketMessage message) {
    final p = WhatsAppMessagePayload.fromMessage(message);
    if (p == null) return null;

    return AppNotification(
      title: 'Mensaje WhatsApp CRM',
      body: _bodyPorTipo(p.tipoMensaje, p.mensaje),
      route: AppRoutes.detalleChat,
      payload: {'idLead': p.leadId.toString()},
    );
  }

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

  String _bodyPorTipo(String tipo, String mensaje) =>
      switch (tipo.toLowerCase()) {
        'image' => '📷 Imagen',
        'audio' => '🎵 Audio',
        'video' => '🎥 Video',
        'document' => '📄 Documento',
        _ => mensaje,
      };
}
