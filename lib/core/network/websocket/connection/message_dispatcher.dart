// lib/core/network/websocket/message_dispatcher.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/navigation/app_route_observer.dart';
import 'package:app_crm/core/network/websocket/parser/websocket_message.dart';
import 'package:app_crm/core/notifications/handlers/notification_handler.dart';
import 'dart:async';

class MessageDispatcher {
  MessageDispatcher._();
  static final MessageDispatcher instance = MessageDispatcher._();

  /// El stream principal — las features siguen escuchando aquí
  final StreamController<WebSocketMessage> _streamController =
      StreamController<WebSocketMessage>.broadcast();

  Stream<WebSocketMessage> get stream => _streamController.stream;

  void dispatch(WebSocketMessage message) {
    final String? route = AppRouteObserver.instance.currentRoute;

    switch (message.process) {
      case 'MENSAJE_WHATSAPP':
        _dispatchWhatsApp(message, route);
      case 'NUEVO_LEAD':
        _dispatchLead(message, route);
      case 'RECORDATORIO':
        _dispatchRecordatorio(message, route);
      default:
        // proceso desconocido → solo al stream por si alguien escucha
        _toStream(message);
    }
  }

  // ── WHATSAPP ────────────────────────────────────────────────

  void _dispatchWhatsApp(WebSocketMessage message, String? route) {
    // Siempre al stream — ChatListBloc y ChatDetailBloc actualizan la UI
    _toStream(message);

    // Notificación solo si NO está viendo ese chat
    final bool enListaChats = route == AppRoutes.chats;
    final bool enEsteDetalle =
        (route == AppRoutes.detalleChat) &&
        (AppRouteObserver.instance.activeLeadId == _leadId(message));

    if (!enListaChats && !enEsteDetalle) {
      NotificationHandler.instance.show(message);
    }
  }

  // ── NUEVO LEAD ───────────────────────────────────────────────

  void _dispatchLead(WebSocketMessage message, String? route) {
    // Al stream — LeadListBloc puede reaccionar si quiere
    _toStream(message);

    // Notificación solo si NO está en lista de leads
    if (route != AppRoutes.leads) {
      NotificationHandler.instance.show(message);
    }
  }

  // ── RECORDATORIO ─────────────────────────────────────────────

  void _dispatchRecordatorio(WebSocketMessage message, String? route) {
    _toStream(message);

    if (route != AppRoutes.recordatorios) {
      NotificationHandler.instance.show(message);
    }
  }

  // ── helpers ──────────────────────────────────────────────────

  void _toStream(WebSocketMessage message) {
    if (!_streamController.isClosed) _streamController.add(message);
  }

  int? _leadId(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    return f.length > 2 ? int.parse(f[2].trim()) : null;
  }

  void dispose() => _streamController.close();
}
