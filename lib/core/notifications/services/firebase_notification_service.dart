// lib/core/notifications/services/firebase_notification_service.dart

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseNotificationService {
  FirebaseNotificationService._();
  static final FirebaseNotificationService instance =
      FirebaseNotificationService._();

  final _fcm = FirebaseMessaging.instance;

  // Evita registrar los listeners más de una vez
  bool _listenersRegistrados = false;

  /// Fase 1 — inicializar sin pedir permisos.
  /// Seguro de llamar en main() antes de runApp().
  /// Si el usuario ya concedió permisos en una sesión anterior, configura
  /// los listeners directamente sin mostrar ningún diálogo.
  Future<void> init() async {
    try {
      final configuracion = await _fcm.getNotificationSettings();

      final yaAutorizado =
          configuracion.authorizationStatus == AuthorizationStatus.authorized ||
          configuracion.authorizationStatus == AuthorizationStatus.provisional;

      if (yaAutorizado) _configurarListeners();

      // Mensaje que lanzó la app desde estado killed (tap en notificación)
      final inicial = await _fcm.getInitialMessage();
      if (inicial != null) _procesarMensaje(inicial, navegarAlAbrir: true);
    } catch (_) {}
  }

  /// Fase 2 — pide permisos al usuario con un timeout de seguridad.
  /// Llamar solo cuando ya hay UI visible (desde el Splash o similar).
  ///
  /// Retorna true si el permiso fue concedido.
  /// Nunca lanza excepción — siempre retorna false ante cualquier error o timeout.
  Future<bool> requestPermissions({
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final configuracion = await _fcm
          .requestPermission(alert: true, badge: true, sound: true)
          .timeout(timeout);

      final concedido =
          configuracion.authorizationStatus == AuthorizationStatus.authorized ||
          configuracion.authorizationStatus == AuthorizationStatus.provisional;

      if (concedido) _configurarListeners();
      return concedido;
    } on TimeoutException {
      // El usuario ignoró el diálogo durante [timeout] — continuar sin bloquear
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Obtiene el token FCM actual.
  /// Solo llamar después de confirmar que el permiso fue concedido.
  Future<String?> obtenerToken() async {
    try {
      return await _fcm.getToken();
    } catch (_) {
      return null;
    }
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  // ── Privado ───────────────────────────────────────────────────

  void _configurarListeners() {
    if (_listenersRegistrados) return;
    _listenersRegistrados = true;

    _fcm.onTokenRefresh.listen((_) {});

    FirebaseMessaging.onMessage.listen((message) {
      _procesarMensaje(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _procesarMensaje(message, navegarAlAbrir: true);
    });
  }

  void _procesarMensaje(RemoteMessage message, {bool navegarAlAbrir = false}) {
    // TEMPORAL — prueba de FCM sin SignalR. Quitar junto con el otro TEMPORAL
    // de auth_bloc.dart cuando se confirme el diagnóstico.
    if (kDebugMode) {
      debugPrint(
        '[FCM] onMessage recibido — data: ${message.data}, '
        'notification.body: ${message.notification?.body}',
      );
    }

    final cuerpo =
        (message.notification?.body ?? message.data['cuerpo'] ?? '')
            .replaceAll('[', '')
            .replaceAll(']', '')
            .trim();

    final wsMessage = WebSocketMessageParser.parse(cuerpo);
    if (wsMessage == null) return;

    if (navegarAlAbrir) {
      final notif = NotificationHandler.instance.parse(wsMessage);
      if (notif != null) NotificationNavigator.instance.navigate(notif);
    } else {
      NotificationHandler.instance.handle(wsMessage);
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await LocalNotificationService.instance.initBackground();
  // Isolate nuevo por cada push con la app cerrada — la BD local no está
  // abierta todavía acá, hace falta inicializarla para persistir mensajes.
  await LocalDatabase().init();

  // Con la app cerrada no hay sesión viva en memoria. Si el Splash no va a
  // poder restaurar sola la sesión guardada (sin "recordar sesión" y sin
  // Google), tocar la notificación llevaría a una pantalla de chat/lead sin
  // token válido — mejor no mostrarla.
  if (!await _haySesionRestaurable()) return;

  final body = message.data['cuerpo'] ?? message.notification?.body;
  if (body == null) return;

  final parsed = WebSocketMessageParser.parse(body);
  if (parsed == null) return;

  // Nunca dejar que una excepción aborte el isolate de background en
  // silencio — sin este try/catch, un fallo acá (parseo del payload,
  // plugin de notificaciones, SQLite) desaparece sin ningún log y la
  // notificación simplemente nunca aparece.
  try {
    switch (parsed.process) {
      case 'NUEVO_LEAD':
        await LocalNotificationService.instance.showLeadNuevoNotification(
          parsed,
        );
      case 'NUEVO_LEAD_BOT':
        await LocalNotificationService.instance.showLeadNuevoBotNotification(
          parsed,
        );
      case 'MENSAJE_WHATSAPP':
        await LocalNotificationService.instance.showChatNotification(parsed);
    }
  } catch (e, st) {
    debugPrint(
      '[FCM background] Error mostrando notificación (${parsed.process}): $e\n$st',
    );
  }
}

/// true si el Splash va a poder restaurar la sesión guardada sola (tabla
/// `session` de SQLite): con "recordar sesión" marcado, o login con Google
/// (que siempre debe poder restaurarse — ver `AuthRepositoryImpl.tryRestoreSession`,
/// misma regla: `!rememberMe && !isGoogle` → no se restaura).
/// 'google' es el literal que persiste `SessionModel.toMap()` en
/// `features/auth/data/models/session_model.dart` — no se importa el enum
/// `LoginType` acá para no acoplar `core/notifications` a `features/auth`.
Future<bool> _haySesionRestaurable() async {
  final rows = await LocalDatabase().getAll('session');
  if (rows.isEmpty) return false;

  final row = rows.first;
  final rememberMe = (row['remember_me'] as int?) == 1;
  final isGoogle = row['login_type'] == 'google';
  return rememberMe || isGoogle;
}
