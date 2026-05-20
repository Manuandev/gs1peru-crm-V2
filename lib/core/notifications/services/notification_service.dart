// lib/core/notifications/services/notification_service.dart

import 'package:app_crm/core/notifications/index_notifications.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {
    await LocalNotificationService.instance.init();
    await FirebaseNotificationService.instance.init();
  }

  // Usado por SignalR (foreground)
  Future<void> show(AppNotification notif) =>
      LocalNotificationService.instance.show(notif);

  Future<void> cancelAll() =>
      LocalNotificationService.instance.cancelAll();
}