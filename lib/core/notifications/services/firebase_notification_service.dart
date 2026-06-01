// lib/core/notifications/services/firebase_notification_service.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  final _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return;
      }

      _fcm.onTokenRefresh.listen((newToken) {});

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final rawBody =
            (message.notification?.body ?? message.data['body'] ?? '')
                .replaceAll('[', '')
                .replaceAll(']', '')
                .trim();

        final wsMessage = WebSocketMessageParser.parse(rawBody);
        if (wsMessage == null) return;

        NotificationHandler.instance.handle(wsMessage);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final rawBody =
            (message.notification?.body ?? message.data['body'] ?? '')
                .replaceAll('[', '')
                .replaceAll(']', '')
                .trim();

        final wsMessage = WebSocketMessageParser.parse(rawBody);
        if (wsMessage == null) return;

        final notif = NotificationHandler.instance.parse(wsMessage);
        if (notif != null) NotificationNavigator.instance.navigate(notif);
      });

      final initial = await _fcm.getInitialMessage();
      if (initial != null) {
        final rawBody =
            (initial.notification?.body ?? initial.data['body'] ?? '')
                .replaceAll('[', '')
                .replaceAll(']', '')
                .trim();

        final wsMessage = WebSocketMessageParser.parse(rawBody);
        if (wsMessage != null) {
          final notif = NotificationHandler.instance.parse(wsMessage);
          if (notif != null) NotificationNavigator.instance.navigate(notif);
        }
      }
    } catch (_) {}
  }

  Future<void> requestPermissions() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    _fcm.onTokenRefresh.listen((_) {});
  }

  Future<String?> obtenerToken() async {
    try {
    final token = await _fcm.getToken();
    return token;
    } catch (_) {
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
