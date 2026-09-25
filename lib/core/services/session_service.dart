// lib/core/services/session_service.dart

import 'package:app_crm/core/index_core.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  UserModel? _user;

  // Unidad de negocio con la que el asesor está trabajando. La fija
  // UnidadCubit (login, restaurar sesión o cambio desde el drawer) — los
  // datasources la leen de acá para mandarla al final del body de cada SP.
  int? _idUnidadActiva;

  // ── GETTERS ─────────────────────────────────────────────
  UserModel? get user => _user;
  String get token => _user?.token ?? '';
  String get codUser => _user?.codUser ?? '';
  String get userApe => _user?.userApe ?? '';
  bool get isModerador => _user?.isModerador ?? false;
  bool get hasSession => _user != null;

  /// Unidades asignadas al asesor, en el orden del login (la primera es la
  /// asignación más reciente).
  List<int> get unidades => _user?.unidades ?? const [];
  bool get tieneUnidades => unidades.isNotEmpty;
  int? get idUnidadActiva => _idUnidadActiva;

  /// Valor listo para el body de los SP — '' si el asesor no tiene unidad
  /// (el SP devuelve vacío en ese caso).
  String get idUnidadBody => _idUnidadActiva?.toString() ?? '';

  // ── MÉTODOS ─────────────────────────────────────────────
  void setUser(UserModel user) => _user = user;
  void setUnidadActiva(int? idUnidad) => _idUnidadActiva = idUnidad;
  void clear() {
    _user = null;
    _idUnidadActiva = null;
  }
}
