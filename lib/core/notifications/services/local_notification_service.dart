// lib/core/notifications/services/local_notification_service.dart

import 'package:app_crm/config/router/app_routes.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

const AndroidNotificationChannel _channel = AndroidNotificationChannel(
  'app_crm_channel',
  'CRM Notificaciones',
  description: 'Notificaciones generales del CRM',
  importance: Importance.max,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final Map<int, List<String>> _mensajesPorLead = {};

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null || response.payload!.isEmpty) return;
        final notif = AppNotification.fromPayloadString(response.payload!);
        NotificationNavigator.instance.navigateWithAction(
          notif,
          actionId: response.actionId,
        );
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    // ✅ FIX: faltaba el < de apertura en ambos resolvePlatformSpecificImplementation
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // No pedir permisos aquí — se hace desde el Splash con UI visible
    _initialized = true;
  }

  Future<void> initBackground() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await flutterLocalNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == null || response.payload!.isEmpty) return;
        final notif = AppNotification.fromPayloadString(response.payload!);
        NotificationNavigator.instance.navigateWithAction(
          notif,
          actionId: response.actionId,
        );
      },
      onDidReceiveBackgroundNotificationResponse: _onBackgroundTap,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    _initialized = true;
  }

  /// Separado — pide permiso con UI ya visible
  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
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
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      payload: notif.toPayloadString(),
    );
  }

  Future<void> showWhatsApp({
    required int leadId,
    required String mensaje,
  }) async {
    _mensajesPorLead[leadId] ??= [];
    _mensajesPorLead[leadId]!.add(mensaje);

    final mensajes = _mensajesPorLead[leadId]!;
    final total = mensajes.length;

    await flutterLocalNotificationsPlugin.show(
      id: leadId,
      title: 'Lead $leadId${total > 1 ? ' ($total mensajes)' : ''}',
      body: mensajes.last,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: InboxStyleInformation(
            mensajes,
            summaryText: '$total mensajes',
          ),
        ),
      ),
      payload: AppNotification(
        title: 'Lead $leadId',
        body: mensajes.last,
        route: AppRoutes.detalleChat,
        payload: {'idNumero': leadId.toString()},
      ).toPayloadString(),
    );
  }

  Future<void> showLeadNuevoNotification(WebSocketMessage parsed) async {
    if (parsed.records.isEmpty) return;
    final f = parsed.records.first;
    String get(int i) => i < f.length ? f[i].trim() : '';

    final leadId = int.tryParse(get(0)) ?? 0;
    if (leadId == 0) return;

    final nombre = get(1);
    final empresa = get(2);
    final canal = f.length > 11 ? get(11) : '';

    final detalles = [
      if (empresa.isNotEmpty) 'Empresa: $empresa',
      if (canal.isNotEmpty) 'Canal: $canal',
    ].join('\n');

    await flutterLocalNotificationsPlugin.show(
      id: leadId,
      title: 'Nuevo lead',
      body: nombre.isNotEmpty ? nombre : 'Sin nombre',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          styleInformation: BigTextStyleInformation(
            detalles.isNotEmpty ? detalles : nombre,
            contentTitle: 'Nuevo lead: $nombre',
            summaryText: canal.isNotEmpty ? canal : null,
          ),
          actions: const [
            AndroidNotificationAction('ver_lead', 'Ver lead'),
            AndroidNotificationAction('abrir_conversacion', 'Abrir conversación'),
          ],
        ),
      ),
      payload: AppNotification(
        title: 'Nuevo lead',
        body: nombre,
        route: AppRoutes.seguimiento,
        payload: {'idLead': leadId.toString(), 'nombre': nombre},
      ).toPayloadString(),
    );
  }

  Future<void> showChatNotification(WebSocketMessage parsed) async {
    final p = WhatsAppMessagePayload.fromMessage(parsed);
    if (p == null) return;
    await showWhatsApp(
      leadId: p.idNumero,
      mensaje: _textoMensaje(p.tipoMensaje, p.mensaje),
    );
  }

  void clearLead(int leadId) {
    _mensajesPorLead.remove(leadId);
    flutterLocalNotificationsPlugin.cancel(id: leadId);
  }

  Future<void> cancelAll() => flutterLocalNotificationsPlugin.cancelAll();

  String _textoMensaje(String tipo, String mensaje) =>
      switch (tipo.toLowerCase()) {
        'image' => '📷 Imagen',
        'audio' => '🎵 Audio',
        'video' => '🎥 Video',
        'document' => '📄 Documento',
        _ => mensaje,
      };
}

@pragma('vm:entry-point')
void _onBackgroundTap(NotificationResponse response) {}
