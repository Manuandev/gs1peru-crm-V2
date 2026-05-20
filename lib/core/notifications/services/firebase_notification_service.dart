// lib/core/notifications/services/firebase_notification_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:app_crm/core/notifications/index_notifications.dart';

class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  final _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');
    // TODO: enviar token al backend

    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token renovado: $newToken');
      // TODO: actualizar en backend
    });

    // ── FOREGROUND → mostramos notif local ──────────────────────
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = _fromRemoteMessage(message);
      if (notif != null) LocalNotificationService.instance.show(notif);
    });

    // ── BACKGROUND → usuario toca ───────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notif = _fromRemoteMessage(message);
      if (notif != null) NotificationNavigator.instance.navigate(notif);
    });

    // ── APP CERRADA → usuario toca ──────────────────────────────
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      final notif = _fromRemoteMessage(initial);
      if (notif != null) NotificationNavigator.instance.navigate(notif);
    }
  }

  AppNotification? _fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final route = data['route'] as String?;
    if (route == null) return null;

    final payload = Map<String, String>.from(data)..remove('route');

    return AppNotification(
      title  : message.notification?.title ?? data['title'] ?? '',
      body   : message.notification?.body  ?? data['body']  ?? '',
      route  : route,
      payload: payload.isEmpty ? null : payload,
    );
  }
}

// ✅ TOP-LEVEL — con Firebase.initializeApp para v4.9.0
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM Background: ${message.messageId}');
}