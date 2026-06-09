// lib/core/notifications/services/firebase_notification_service.dart

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

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
    final cuerpo =
        (message.notification?.body ?? message.data['body'] ?? '')
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
}
