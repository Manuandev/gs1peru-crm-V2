// lib/core/notifications/services/local_notification_service.dart

import 'package:app_crm/config/router/app_routes.dart';
import 'package:app_crm/index_dependencies.dart';
import 'package:flutter/foundation.dart';

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
  ///
  /// Cada paso está protegido por separado: en el isolate de background que
  /// crea FCM con la app cerrada, `getActiveNotifications()` o la lectura de
  /// SQLite pueden fallar (plugin/canal de plataforma sin registrar del todo
  /// en ese isolate) — si eso ocurre, el historial se pierde pero la
  /// notificación del mensaje nuevo debe mostrarse igual, nunca abortar en
  /// silencio antes de llegar a `showWhatsApp`.
  Future<List<String>> _agregarMensajePersistido({
    required int idNumero,
    required String mensaje,
  }) async {
    final db = LocalDatabase();
    final key = '$_settingsKeyPrefix$idNumero';

    bool sigueActiva = false;
    try {
      final activas = await flutterLocalNotificationsPlugin
          .getActiveNotifications();
      sigueActiva = activas.any((n) => n.id == idNumero);
    } catch (e) {
      debugPrint('[LocalNotificationService] getActiveNotifications falló: $e');
    }

    String? raw;
    if (sigueActiva) {
      try {
        raw = await db.getSetting(key);
      } catch (e) {
        debugPrint('[LocalNotificationService] getSetting falló: $e');
      }
    }

    final mensajes = raw != null && raw.isNotEmpty
        ? raw.split(AppConstants.sepRegistros)
        : <String>[];
    mensajes.add(mensaje);

    try {
      await db.setSetting(key, mensajes.join(AppConstants.sepRegistros));
    } catch (e) {
      debugPrint('[LocalNotificationService] setSetting falló: $e');
    }

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

  /// Notificación cuando el bot deriva una conversación nueva. El backend le
  /// manda esta misma trama tanto al asesor asignado (`codAsesor`) como a su
  /// supervisor (`incluirSupervisores` en `FcmService.EnviarAsync`, ver
  /// notifications/CLAUDE.md) — el texto cambia según quién la reciba.
  /// Compara contra `cod_user` leído de SQLite (tabla `session`), no contra
  /// `SessionService()`: este método corre igual desde el isolate de FCM en
  /// background (app cerrada, `SessionService` vacío) que desde SignalR en
  /// foreground, y ambos flujos deben mostrar exactamente el mismo texto.
  Future<void> showLeadNuevoBotNotification(WebSocketMessage parsed) async {
    final payload = NuevoLeadBotPayload.fromMessage(parsed);
    if (payload == null) return;

    final codUserPropio = await _codUserPropio();
    final esDestinatario =
        codUserPropio.isNotEmpty && codUserPropio == payload.codAsesor;

    // Nota: no tenemos el nombre del asesor asignado — NuevoLeadBotPayload
    // (trama NUEVO_LEAD_BOT) solo trae `codAsesor` (código), y el catálogo
    // de asesores no está persistido en SQLite para poder resolverlo en el
    // isolate de FCM en background. Se muestra el código.
    final String titulo;
    final String cuerpo;
    if (esDestinatario) {
      titulo = 'Te asignaron una nueva conversación derivada por el bot';
      cuerpo = 'Por favor, atiéndela a la brevedad.';
    } else {
      titulo = 'Se derivó una conversación al asesor ${payload.codAsesor}';
      cuerpo = 'Podrás darle el seguimiento desde el detalle.';
    }

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
            // 'Ver negociación' → AppRoutes.detalleSeguimiento con idLead
            // (mismo destino que 'ver_lead' — ver notification_navigator.dart,
            // bug real corregido 2026-08-20: antes mandaba a
            // AppRoutes.detalleContacto con idNumero, pero esa ruta ya
            // requiere idContacto desde la migración documentada en
            // lead/CLAUDE.md — el payload de NUEVO_LEAD_BOT nunca trajo
            // idContacto, así que siempre reventaba con pantalla en blanco).
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
        // Tap en el cuerpo (sin botón de acción) → Conversaciones, mismo
        // destino que el botón "Abrir conversación" — pedido de negocio.
        // navigate() en NotificationNavigator resuelve esto a _goChat con el
        // idChatCab de abajo.
        route: AppRoutes.chats,
        payload: {
          'idLead': payload.idLead.toString(),
          'codAsesor': payload.codAsesor,
          'nombreCliente': payload.nombreCliente,
          'numero': payload.numero,
          'idChatCab': payload.idChatCab.toString(),
          'idNumero': payload.idNumero.toString(),
          'idContacto': payload.idContacto.toString(),
        },
      ).toPayloadString(),
    );
  }

  /// Código del usuario actual leído directo de SQLite (tabla `session`,
  /// columna `cod_user`) — no de `SessionService()`, que vive en memoria y
  /// está vacío en el isolate de FCM en background (app cerrada). Se
  /// persiste en todo login (ver auth/CLAUDE.md → "cod_user"), así que está
  /// disponible sin importar cómo llegó la notificación.
  Future<String> _codUserPropio() async {
    try {
      final rows = await LocalDatabase().getAll('session');
      if (rows.isEmpty) return '';
      return (rows.first['cod_user'] as String?)?.trim() ?? '';
    } catch (e) {
      debugPrint('[LocalNotificationService] _codUserPropio falló: $e');
      return '';
    }
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
