// lib/core/notifications/handlers/notification_navigator.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

class NotificationNavigator {
  NotificationNavigator._();
  static final NotificationNavigator instance = NotificationNavigator._();

  void navigate(AppNotification notif) {
    final route = notif.route;
    if (route == null) return;

    if (route.startsWith(AppRoutes.chats)) return _goChat(notif);
    // if (route.startsWith(AppRoutes.leads)) return _goLead(notif);
    

    _go(route);
  }

  void _goChat(AppNotification notif) {
    final idLead = notif.payload?['idLead'] ?? '';
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return;

    state.pushNamedAndRemoveUntil(AppRoutes.chats, (r) => false);
    state.pushNamed(AppRoutes.detalleChat, arguments: {'idLead': idLead});
  }

  // void _goLead(AppNotification notif) => _go(AppRoutes.leads); // TODO

  void _go(String route) {
    NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }
}
