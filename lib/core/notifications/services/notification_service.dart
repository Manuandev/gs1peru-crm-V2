// lib/core/notifications/services/notification_service.dart

import 'package:app_crm/core/index_core.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> init() async {
    await LocalNotificationService.instance.init();
    await FirebaseNotificationService.instance.init();
  }

  Future<void> initBackground() async {
    await LocalNotificationService.instance.initBackground();
    await FirebaseNotificationService.instance.init();
  }

  /// Llamado desde el Splash — aquí sí pide permisos (ya hay UI)
  Future<void> requestPermissions() async {
    await LocalNotificationService.instance.requestPermissions();
    await FirebaseNotificationService.instance.requestPermissions();
  }

  // Usado por SignalR (foreground)
  Future<void> show(AppNotification notif) =>
      LocalNotificationService.instance.show(notif);

  Future<void> cancelAll() => LocalNotificationService.instance.cancelAll();
}
