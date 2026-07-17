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

  // Máximo de mensajes visibles en el desplegable — evita saturar la
  // notificación cuando llegan muchos; el contador del summary sí es el real.
  static const int _maxMensajesVisibles = 3;

  // Prefijo de la clave en `settings` donde se acumulan los mensajes no
  // leídos por número. Persistido en SQLite (no en memoria) porque el
  // handler de FCM en background corre en un isolate nuevo por cada push
  // con la app cerrada — un Map en memoria perdería el conteo entre uno
  // y otro.
  static const String _settingsKeyPrefix = 'notif_msgs_';

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

  /// Notificación de mensaje entrante — agrupada por [idNumero], igual que
  /// WhatsApp agrupa por contacto (no por lead: un mismo número puede pasar
  /// por varios leads sin que la conversación cambie).
  /// Título: "Nombre - numero" si hay nombre, si no solo "numero".
  Future<void> showWhatsApp({
    required int idNumero,
    required int idChatCab,
    required String numero,
    required String mensaje,
    String? nombreCliente,
  }) async {
    final mensajes = await _agregarMensajePersistido(
      idNumero: idNumero,
      mensaje: mensaje,
    );

    final total = mensajes.length;
    final mensajesVisibles = total > _maxMensajesVisibles
        ? mensajes.sublist(total - _maxMensajesVisibles)
        : mensajes;

    final contacto = (nombreCliente != null && nombreCliente.isNotEmpty)
        ? '$nombreCliente - $numero'
        : numero;
    final titulo = total > 1 ? '$contacto ($total mensajes)' : contacto;

    await flutterLocalNotificationsPlugin.show(
      id: idNumero,
      title: titulo,
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
            mensajesVisibles,
            summaryText: '$total mensajes',
          ),
        ),
      ),
      payload: AppNotification(
        title: contacto,
        body: mensajes.last,
        route: AppRoutes.detalleChat,
        payload: {'idChatCab': idChatCab.toString()},
      ).toPayloadString(),
    );
  }

  /// Lee de `settings` los mensajes acumulados de [idNumero], agrega
  /// [mensaje] y persiste la lista completa de vuelta. Persistido (no en
  /// memoria) porque el handler de FCM en background corre en un isolate
  /// nuevo por cada push con la app cerrada.
  ///
  /// Si el usuario descartó (swipe) la notificación anterior, Android ya no
  /// la tiene activa aunque el historial siga en SQLite — sin este chequeo
  /// el contador quedaba "pegado" (ej. seguía en "11 mensajes" después de
  /// descartarla). Se arranca de cero cuando no hay una notificación activa
  /// con ese id.
  Future<List<String>> _agregarMensajePersistido({
    required int idNumero,
    required String mensaje,
  }) async {
    final db = LocalDatabase();
    final key = '$_settingsKeyPrefix$idNumero';

    final activas = await flutterLocalNotificationsPlugin.getActiveNotifications();
    final sigueActiva = activas.any((n) => n.id == idNumero);

    final raw = sigueActiva ? await db.getSetting(key) : null;

    final mensajes = raw != null && raw.isNotEmpty
        ? raw.split(AppConstants.sepRegistros)
        : <String>[];
    mensajes.add(mensaje);

    await db.setSetting(key, mensajes.join(AppConstants.sepRegistros));
    return mensajes;
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
            AndroidNotificationAction(
              'ver_lead',
              'Ver lead',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'abrir_conversacion',
              'Abrir conversación',
              showsUserInterface: true,
            ),
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

  /// Notificación cuando el bot deriva una conversación nueva a un asesor.
  /// Body fijo — no usa datos del cliente, solo avisa que hay algo pendiente.
  Future<void> showLeadNuevoBotNotification(WebSocketMessage parsed) async {
    final payload = NuevoLeadBotPayload.fromMessage(parsed);
    if (payload == null) return;

    const titulo = 'Nuevo lead derivado por el bot';
    const cuerpo =
        'Una conversación te ha sido derivada, atiéndela lo más pronto posible.';

    await flutterLocalNotificationsPlugin.show(
      id: payload.idLead,
      title: titulo,
      body: cuerpo,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          actions: const [
            // 'Ver lead' → AppRoutes.detalleContacto con idNumero.
            AndroidNotificationAction(
              'ver_negociacion_bot',
              'Ver negociación',
              showsUserInterface: true,
            ),
            AndroidNotificationAction(
              'abrir_conversacion_bot',
              'Abrir conversación',
              showsUserInterface: true,
            ),
          ],
        ),
      ),
      payload: AppNotification(
        title: titulo,
        body: cuerpo,
        payload: {
          'idLead': payload.idLead.toString(),
          'codAsesor': payload.codAsesor,
          'nombreCliente': payload.nombreCliente,
          'numero': payload.numero,
          'idChatCab': payload.idChatCab.toString(),
          'idNumero': payload.idNumero.toString(),
        },
      ).toPayloadString(),
    );
  }

  Future<void> showChatNotification(WebSocketMessage parsed) async {
    final p = WhatsAppMessagePayload.fromMessage(parsed);
    if (p == null) return;
    await showWhatsApp(
      idNumero: p.idNumero,
      idChatCab: p.idChatCab,
      numero: p.telefono,
      mensaje: _textoMensaje(p.tipoMensaje, p.mensaje),
    );
  }

  Future<void> clearLead(int idNumero) async {
    await LocalDatabase().deleteSetting('$_settingsKeyPrefix$idNumero');
    await flutterLocalNotificationsPlugin.cancel(id: idNumero);
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
