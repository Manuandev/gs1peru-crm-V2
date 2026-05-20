// lib/core/notifications/handlers/notification_navigator.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/notifications/index_notifications.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class NotificationNavigator {
  NotificationNavigator._();
  static final NotificationNavigator instance = NotificationNavigator._();

  void navigate(AppNotification notif) {
    final route = notif.route;
    if (route == null) return;

    if (route.startsWith(AppRoutes.chats)) return _goChat(notif);
    if (route.startsWith(AppRoutes.leads)) return _goLead(notif);
    if (route.startsWith(AppRoutes.recordatorios)) {
      return _goRecordatorio(notif);
    }

    _go(route);
  }

  void _goChat(AppNotification notif) {
    final p = notif.payload ?? {};
    final state = NavigationService.navigatorKey.currentState; 
    if (state == null) return;

    final chat = ChatModel(
      idChatCab: p['idChatCab'] ?? '',
      idLead: p['idLead'] ?? '',
      nombreApe: p['nombre'] ?? '',
      telefono: p['telefono'] ?? '',
      mensaje: '',
      fechaHora: '',
      isFavorito: false,
      isEnviado: false,
      isBloqueado: false,
    );

    // ✅ Mismo comportamiento que goToDetalleChatDesdeHome
    state.pushNamedAndRemoveUntil(AppRoutes.chats, (r) => false);
    state.pushNamed(AppRoutes.detalleChat, arguments: {'chat': chat});
  }

  void _goLead(AppNotification notif) => _go(AppRoutes.leads); // TODO
  void _goRecordatorio(AppNotification notif) =>
      _go(AppRoutes.recordatorios); // TODO

  void _go(String route) {
    NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }
}
