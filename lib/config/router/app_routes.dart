// lib/config/router/app_routes.dart

/// Constantes de rutas - Type-safe
class AppRoutes {
  AppRoutes._();

  // ============================================================
  // RUTAS PRINCIPALES
  // ============================================================
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String changePassword = '/cambiar-contrasena';
  static const String settings = '/settings';

  // ============================================================
  // MÓDULOS
  // ============================================================
  static const String leads = '/leads';
  static const String chats = '/chats';
  static const String propuestas = '/propuestas';
  static const String prospectos = '/prospectos';
  static const String cobranza = '/cobranza';


  // ============================================================
  // SUB-RUTAS HOME
  // ============================================================
  static const String notifications = '/home/notifications';

  // ============================================================
  // SUB-RUTAS LEADS
  // ============================================================

  // ============================================================
  // SUB-RUTAS CHATS
  // ============================================================
  static const String detalleChat = '/chats/detalle';
  static const String detalleEditarLead = '/chats/detalle/editar-lead';

  // ============================================================
  // SUB-RUTAS PROSPECTOS
  // ============================================================
  static const String detalleProspecto = '/prospectos/detalle';

  // ============================================================
  // SUB-RUTAS PROPUESTAS
  // ============================================================
  static const String detallePropuesta = '/propuestas/detalle';

  // ============================================================
  // SUB-RUTAS COBRANZAS
  // ============================================================
  static const String detalleCobranza = '/cobranza/detalle';
}
