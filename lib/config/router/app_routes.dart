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

  // ============================================================
  // MÓDULOS
  // ============================================================ 
  static const String leads = '/leads';
  static const String recordatorios = '/recordatorios';
  static const String chats = '/chats';
  static const String cobranza = '/cobranza';

  // ============================================================
  // SUB-RUTAS LEADS
  // ============================================================
  static const String leadInfo = '/leads/informacion';
  static const String leadInfos = '/leads/nose';

}
