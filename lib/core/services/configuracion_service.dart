// lib/core/services/configuracion_service.dart

import 'package:app_crm/core/index_core.dart';

/// Singleton en memoria que almacena la configuración global de la app.
/// Se carga durante el splash y está disponible para toda la sesión.
/// Sigue el mismo patrón que SessionService.
class ConfiguracionService {
  static final ConfiguracionService _instance = ConfiguracionService._internal();
  factory ConfiguracionService() => _instance;
  ConfiguracionService._internal();

  AppConfiguracion? _config;

  // ── GETTERS ─────────────────────────────────────────────
  AppConfiguracion? get config => _config;
  double get tiempoChatAbierto => _config?.tiempoChatAbierto ?? 15.0;
  TipoLoginApp get tipoLogin => _config?.tipoLogin ?? TipoLoginApp.credenciales;
  bool get cargada => _config != null;

  // ── MÉTODOS ─────────────────────────────────────────────
  void guardar(AppConfiguracion config) => _config = config;
  void limpiar() => _config = null;
}
