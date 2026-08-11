// lib/core/notifications/handlers/notification_handler.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

class NotificationHandler {
  NotificationHandler._();
  static final NotificationHandler instance = NotificationHandler._();

  void show(WebSocketMessage message) {
    final notif = parse(message);
    if (notif != null) NotificationService.instance.show(notif);
  }

  void handle(WebSocketMessage message) {
    final notif = parse(message);
    if (notif == null) return;
    if (_isSuppressed(message)) return;
    NotificationService.instance.show(notif);
  }

  bool _isSuppressed(WebSocketMessage message) {
    final String? route = AppRouteObserver.instance.currentRoute;

    return switch (message.process) {
      'MENSAJE_WHATSAPP' => _suppressWhatsApp(route, message),
      'NUEVO_LEAD' => route == AppRoutes.seguimiento,
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

  AppNotification? parse(WebSocketMessage message) {
    return switch (message.process) {
      'MENSAJE_WHATSAPP' => _parseWhatsApp(message),
      'NUEVO_LEAD' => _parseLead(message),
      'NUEVO_LEAD_BOT' => _parseLeadBot(message),
      _ => null,
    };
  }

  AppNotification? _parseWhatsApp(WebSocketMessage message) {
    final p = WhatsAppMessagePayload.fromMessage(message);
    if (p == null) return null;

    // Un mensaje de WhatsApp solo debe notificarle al asesor asignado a ese
    // chat — a diferencia de NUEVO_LEAD_BOT, nunca le llega al supervisor.
    if (p.codAsesor != SessionService().codUser) return null;

    LocalNotificationService.instance.showWhatsApp(
      idNumero: p.idNumero,
      idChatCab: p.idChatCab,
      numero: p.telefono,
      mensaje: _bodyPorTipo(p.tipoMensaje, p.mensaje),
    );

    return null;
  }

  // ignore: unused_element — se dispara como side-effect; retorna null intencionalmente
  AppNotification? _parseLead(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    // fire-and-forget: showLeadNuevoNotification es async pero no necesitamos await aquí
    LocalNotificationService.instance.showLeadNuevoNotification(message);
    return null;
  }

  // ignore: unused_element — se dispara como side-effect; retorna null intencionalmente
  AppNotification? _parseLeadBot(WebSocketMessage message) {
    if (message.records.isEmpty) return null;

    // A diferencia del push FCM (backend, incluirSupervisores en
    // FcmService.EnviarAsync — filtra el destinatario del lado del
    // servidor), este mensaje llega por el broadcast de SignalR SIN
    // distinción de destinatario a todos los conectados. Sin este filtro,
    // cualquier asesor con la app abierta veía la derivación de leads
    // ajenos (bug real detectado en vivo 2026-08-11). Solo debe verla el
    // asesor asignado o un moderador (supervisor).
    final payload = NuevoLeadBotPayload.fromMessage(message);
    if (payload != null &&
        payload.codAsesor != SessionService().codUser &&
        !SessionService().isModerador) {
      return null;
    }

    // fire-and-forget: showLeadNuevoBotNotification es async pero no necesitamos await aquí
    LocalNotificationService.instance.showLeadNuevoBotNotification(message);
    return null;
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
