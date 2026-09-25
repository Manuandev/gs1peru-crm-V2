// lib/core/notifications/handlers/notification_navigator.dart

import 'package:app_crm/config/index_config.dart';
import 'package:app_crm/core/index_core.dart';

class NotificationNavigator {
  NotificationNavigator._();
  static final NotificationNavigator instance = NotificationNavigator._();

  // getNotificationAppLaunchDetails() sigue devolviendo la misma trama por
  // toda la vida del proceso — sin este guard, un segundo AuthAuthenticated
  // en la misma sesión de app (ej. logout y volver a loguear sin cerrar la
  // app) reprocesaría el mismo cold-start launch y navegaría de nuevo.
  bool _launchProcesado = false;

  Future<void> navigate(AppNotification notif) async {
    final route = notif.route;
    if (route == null) return;
    await _asegurarUnidad(notif);

    if (route.startsWith(AppRoutes.chats)) return _goChat(notif);
    if (route.startsWith(AppRoutes.seguimiento)) return _goLead(notif);

    _go(route);
  }

  /// Navega según el botón de acción que tocó el usuario.
  /// Llamado desde onDidReceiveNotificationResponse con response.actionId.
  Future<void> navigateWithAction(
    AppNotification notif, {
    String? actionId,
  }) async {
    // Notificación de otra unidad del asesor → primero cambia a esa unidad,
    // así la lista de destino (y Home debajo) cargan con la unidad correcta.
    await _asegurarUnidad(notif);
    switch (actionId) {
      case 'ver_lead':
        _goLead(notif);
      case 'abrir_conversacion':
        _goChat(notif);
      case 'ver_negociacion_bot':
        _goSeguimiento(notif);
        break;
      case 'abrir_conversacion_bot':
        _goChat(notif);
      default:
        navigate(notif);
    }
  }

  /// Detecta si la app fue abierta (cold start) desde el tap de una
  /// notificación local — sea que el tap fue en el cuerpo o en un botón de
  /// acción, ninguno de los dos pasa por `onDidReceiveNotificationResponse`
  /// cuando la app estaba totalmente cerrada (limitación documentada del
  /// plugin), así que este es el único lugar donde ese tap se puede leer.
  ///
  /// Llamar solo después de que la sesión ya se resolvió (`AuthAuthenticated`)
  /// — necesita `SessionService().hasSession` poblado para que la guardia de
  /// `_goChat`/`_goLead` decida bien, y necesita que Home ya esté en la base
  /// del stack para poder apilar el detalle encima.
  Future<void> handleLocalNotificationLaunch() async {
    if (_launchProcesado) return;
    _launchProcesado = true;

    final details =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return;
    final response = details!.notificationResponse;
    if (response?.payload == null || response!.payload!.isEmpty) return;
    final notif = AppNotification.fromPayloadString(response.payload!);
    await navigateWithAction(notif, actionId: response.actionId);
  }

  /// Si la notificación trae `idUnidad` de otra unidad asignada al asesor,
  /// la activa antes de navegar (pedido de negocio: cambio automático, sin
  /// preguntar). Sin sesión o sin unidad en el payload, no hace nada.
  Future<void> _asegurarUnidad(AppNotification notif) async {
    if (!SessionService().hasSession) return;
    final idUnidad = int.tryParse(notif.payload?['idUnidad'] ?? '');
    if (idUnidad == null) return;
    await UnidadCubit.instance.cambiarUnidad(idUnidad);
  }

  void _goChat(AppNotification notif) {
    if (!SessionService().hasSession) return _go(AppRoutes.login);

    final idChatCab = int.tryParse(notif.payload?['idChatCab'] ?? '') ?? 0;
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return;

    state.pushNamedAndRemoveUntil(AppRoutes.chats, (r) => false);
    state.pushNamed(AppRoutes.detalleChat, arguments: {'idChatCab': idChatCab});
  }

  void _goLead(AppNotification notif) {
    if (!SessionService().hasSession) return _go(AppRoutes.login);

    final idLead = int.tryParse(notif.payload?['idLead'] ?? '') ?? 0;
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return;

    if (idLead == 0) {
      state.pushNamedAndRemoveUntil(AppRoutes.seguimiento, (r) => false);
      return;
    }
    state.pushNamedAndRemoveUntil(AppRoutes.seguimiento, (r) => false);
    state.pushNamed(
      AppRoutes.detalleSeguimiento,
      arguments: {'idLead': idLead},
    );
  }

  void _goSeguimiento(AppNotification notif) {
    if (!SessionService().hasSession) return _go(AppRoutes.login);

    // idContacto, no idNumero — AppRoutes.detalleContacto exige esa key
    // (args['idContacto'] as int, cast estricto). NUEVO_LEAD_BOT solo trae
    // idContacto real desde el campo [6] agregado 2026-08-20 — antes de eso
    // no había forma de armar esta ruta sin reventar, ver
    // notifications/CLAUDE.md.
    final idContacto = int.tryParse(notif.payload?['idContacto'] ?? '') ?? 0;
    final state = NavigationService.navigatorKey.currentState;
    if (state == null) return;

    if (idContacto == 0) {
      state.pushNamedAndRemoveUntil(AppRoutes.seguimiento, (r) => false);
      return;
    }
    state.pushNamedAndRemoveUntil(AppRoutes.seguimiento, (r) => false);
    state.pushNamed(
      AppRoutes.detalleContacto,
      arguments: {'idContacto': idContacto},
    );
  }

  void _go(String route) {
    NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }
}
