// lib/config/router/app_routes.dart

/// Constantes de rutas de la aplicación.
///
/// Convención de nombrado:
/// - Módulos raíz:     /modulo
/// - Sub-rutas:        /modulo/accion
/// - Sub-sub-rutas:    /modulo/seccion/accion
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String changePassword = '/cambiar-contrasena';
  static const String settings = '/settings';

  static const String chats = '/chats';
  static const String seguimiento = '/seguimiento';
  static const String propuestas = '/propuestas';
  static const String cobranza = '/cobranza';

  static const String notifications = '/home/notifications';

  static const String detalleChat = '/chats/detalle';
  static const String detalleEditarLead = '/chats/detalle/editar-lead';
  static const String templates = '/chats/templates';

  static const String detalleSeguimiento = '/seguimiento/detalle';
  static const String detallePropuesta = '/propuestas/detalle';
  static const String detalleCobranza = '/cobranza/detalle';
  static const String facturarCobranza = '/cobranza/facturar';
  static const String planCredito = '/cobranza/plan-credito';

  static const String mediaPicker = '/media-picker';
}
