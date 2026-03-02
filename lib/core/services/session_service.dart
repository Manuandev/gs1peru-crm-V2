// lib/core/services/session_service.dart

import 'package:app_crm/core/database/models/user_model.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  UserModel? _user;

  // ── GETTERS ─────────────────────────────────────────────
  UserModel? get user => _user;
  String get token => _user?.token ?? '';
  String get codUser => _user?.codUser ?? '';
  String get userApe => _user?.userApe ?? '';
  bool get hasSession => _user != null;

  // ── MÉTODOS ─────────────────────────────────────────────
  void setUser(UserModel user) => _user = user;
  void clear() => _user = null;
}
