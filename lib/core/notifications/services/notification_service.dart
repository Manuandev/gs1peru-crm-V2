// lib/core/notifications/services/notification_service.dart

import 'package:app_crm/core/index_core.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  /// Fase 1 — inicializar sin mostrar diálogos.
  /// Llamar en main() antes de runApp(). No bloquea el arranque de la app.
  Future<void> init() async {
    await LocalNotificationService.instance.init();
    await FirebaseNotificationService.instance.init();
  }

  /// Fase 1 background — para el handler de FCM en background/killed.
  Future<void> initBackground() async {
    await LocalNotificationService.instance.initBackground();
    await FirebaseNotificationService.instance.init();
  }

  /// Fase 2 — pide permisos al usuario.
  /// Llamar solo cuando hay UI visible (desde el Splash).
  /// Nunca bloquea indefinidamente — tiene timeout interno.
  /// Retorna true si ambos permisos fueron concedidos.
  Future<bool> requestPermissions() async {
    // Primero Android (flutter_local_notifications), luego iOS (FCM)
    await LocalNotificationService.instance.requestPermissions();
    return FirebaseNotificationService.instance.requestPermissions();
  }

  // Usado por SignalR (foreground)
  Future<void> show(AppNotification notif) =>
      LocalNotificationService.instance.show(notif);

  Future<void> cancelAll() => LocalNotificationService.instance.cancelAll();
}
