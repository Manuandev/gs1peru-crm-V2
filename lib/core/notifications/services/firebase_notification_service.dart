import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
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
        debugPrint('[FCM] Permiso no concedido');
        return;
      }

      // foreground → mostrar notif local
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
    } catch (e) {
      debugPrint('[FCM] Error inicializando: $e');
    }
  }

  Future<String?> obtenerToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint('[FCM] Error obteniendo token: $e');
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


/*
// lib/core/notifications/services/firebase_notification_service.dart

import 'package:app_crm/core/index_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

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

  Future<void> initBackground() async {
    // ── FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notif = _fromRemoteMessage(message);
      if (notif != null) LocalNotificationService.instance.show(notif);
    });

    // ── BACKGROUND tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notif = _fromRemoteMessage(message);
      if (notif != null) NotificationNavigator.instance.navigate(notif);
    });

    // ── APP CERRADA tap
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      final notif = _fromRemoteMessage(initial);
      if (notif != null) NotificationNavigator.instance.navigate(notif);
    }
  }

  Future<void> requestPermissions() async {
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    final token = await _fcm.getToken();
    debugPrint('FCM Token: $token');

    _fcm.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token renovado: $newToken');
    });
  }

  AppNotification? _fromRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final route = data['route'] as String?;
    if (route == null) return null;

    final payload = Map<String, String>.from(data)..remove('route');

    return AppNotification(
      title: message.notification?.title ?? data['title'] ?? '',
      body: message.notification?.body ?? data['body'] ?? '',
      route: route,
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
*/