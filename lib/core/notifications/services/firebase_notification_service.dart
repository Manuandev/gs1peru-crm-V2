// lib/core/notifications/services/firebase_notification_service.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:flutter/material.dart';

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
        debugPrint('>>> FCM: permiso no concedido');
        return;
      }

      // ✅ Aquí sí, ya tiene permiso
      final token = await _fcm.getToken();
      debugPrint('>>> FCM TOKEN: $token');

      _fcm.onTokenRefresh.listen((newToken) {});

      FirebaseMessaging.onMessage.listen((message) {
        final titulo =
            message.data['titulo'] ?? message.notification?.title ?? '';
        final cuerpo =
            message.data['cuerpo'] ?? message.notification?.body ?? '';

        if (titulo.isEmpty && cuerpo.isEmpty) return;
        LocalNotificationService.instance.show(
          AppNotification(title: titulo, body: cuerpo),
        );
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final notif = _fromRemoteMessage(message);
        if (notif != null) NotificationNavigator.instance.navigate(notif);
      });

      final initial = await _fcm.getInitialMessage();
      if (initial != null) {
        final notif = _fromRemoteMessage(initial);
        if (notif != null) NotificationNavigator.instance.navigate(notif);
      }
    } catch (e) {
      debugPrint('>>> FCM ERROR: $e'); // ← cambia el catch silencioso también
    }
  }

  Future<void> requestPermissions() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);
    _fcm.onTokenRefresh.listen((_) {});
  }

  Future<String?> obtenerToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  AppNotification? _fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final route = data['route'] as String?;
    // if (route == null) return null;

    final payload = Map<String, String>.from(data)..remove('route');

    return AppNotification(
      title: message.notification?.title ?? data['title'] ?? '',
      body: message.notification?.body ?? data['body'] ?? '',
      route: route,
      payload: payload.isEmpty ? null : payload,
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
