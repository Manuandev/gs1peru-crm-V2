// lib/core/network/websocket/message_dispatcher.dart

import 'dart:async';

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

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
      case 'UPDATE_PANTALLA_WHATSAPP':
        _dispatchUpdatePantalla(message, route);
      case 'UPDATE_MENSAJE_WHATSAPP':
        _dispatchUpdateMensaje(message, route);
      // case 'NUEVO_LEAD':
      //   _dispatchLead(message, route);
      default:
        // proceso desconocido → solo al stream por si alguien escucha
        _toStream(message);
    }
  }

  // ── WHATSAPP — Mensaje entrante del cliente ───────────────────

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

  // ── UPDATE_PANTALLA — Confirmación de mensaje enviado por el asesor ──

  void _dispatchUpdatePantalla(WebSocketMessage message, String? route) {
    // Al stream — ChatDetailBloc actualiza el mensaje wait → sent
    _toStream(message);

    // No se muestra notificación — es nuestro propio mensaje confirmado
  }

  // ── UPDATE_MENSAJE — Cambio de estado de un mensaje ──────────

  void _dispatchUpdateMensaje(WebSocketMessage message, String? route) {
    // Al stream — ChatDetailBloc actualiza los checks (sent/delivered/read)
    _toStream(message);

    // No se muestra notificación — es un cambio de estado silencioso
  }

  // ── NUEVO LEAD ───────────────────────────────────────────────

  // void _dispatchLead(WebSocketMessage message, String? route) {
  //   // Al stream — LeadListBloc puede reaccionar si quiere
  //   _toStream(message);

  //   // Notificación solo si NO está en lista de leads
  //   if (route != AppRoutes.leads) {
  //     NotificationHandler.instance.show(message);
  //   }
  // }

  // ── helpers ──────────────────────────────────────────────────

  void _toStream(WebSocketMessage message) {
    if (!_streamController.isClosed) _streamController.add(message);
  }

  int? _leadId(WebSocketMessage message) {
    if (message.records.isEmpty) return null;
    final f = message.records.first;
    return f.length > 2 ? int.tryParse(f[2].trim()) : null;
  }

  void dispose() => _streamController.close();
}
