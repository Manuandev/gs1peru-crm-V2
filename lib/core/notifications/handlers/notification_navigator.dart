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
    if (route.startsWith(AppRoutes.seguimiento)) return _goLead(notif);

    _go(route);
  }

  /// Navega según el botón de acción que tocó el usuario.
  /// Llamado desde onDidReceiveNotificationResponse con response.actionId.
  void navigateWithAction(AppNotification notif, {String? actionId}) {
    switch (actionId) {
      case 'ver_lead':
        _goLead(notif);
      case 'abrir_conversacion':
        _goChat(notif);
      default:
        navigate(notif);
    }
  }

  /// Detecta si la app fue abierta desde una notificación local en estado killed.
  /// Llamar después de que el navigator key esté inicializado (ej: desde Splash).
  Future<void> handleLocalNotificationLaunch() async {
    final details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return;
    final response = details!.notificationResponse;
    if (response?.payload == null || response!.payload!.isEmpty) return;
    final notif = AppNotification.fromPayloadString(response.payload!);
    navigateWithAction(notif, actionId: response.actionId);
  }

  void _goChat(AppNotification notif) {
    final idNumero = notif.payload?['idNumero'] ?? '';
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return;

    state.pushNamedAndRemoveUntil(AppRoutes.chats, (r) => false);
    state.pushNamed(AppRoutes.detalleChat, arguments: {'idNumero': idNumero});
  }

  void _goLead(AppNotification notif) {
    final idLead = int.tryParse(notif.payload?['idLead'] ?? '') ?? 0;
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return;

    if (idLead == 0) {
      state.pushNamedAndRemoveUntil(AppRoutes.seguimiento, (r) => false);
      return;
    }
    state.pushNamedAndRemoveUntil(AppRoutes.seguimiento, (r) => false);
    state.pushNamed(
      AppRoutes.detalleSeguimiento,
      arguments: {'idLead': idLead},
    );
  }

  void _go(String route) {
    NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }
}
