// lib/core/notifications/services/local_notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_crm/core/notifications/index_notifications.dart';

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'app_crm_channel',
  'CRM Notificaciones',
  description: 'Notificaciones generales del CRM',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null || response.payload!.isEmpty) return;
        final notif = AppNotification.fromPayloadString(response.payload!);
        NotificationNavigator.instance.navigate(notif);
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    // ✅ FIX: faltaba el < de apertura en ambos resolvePlatformSpecificImplementation
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> show(AppNotification notif) async {
    await flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: notif.title,
      body: notif.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      payload: notif.toPayloadString(),
    );
  }

  Future<void> cancelAll() => flutterLocalNotificationsPlugin.cancelAll();
}

@pragma('vm:entry-point')
void _onBackgroundTap(NotificationResponse response) {}
