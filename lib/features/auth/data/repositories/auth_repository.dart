// lib/features/auth/data/repositories/auth_repository.dart
// ============================================================
// LOGIN NORMAL (recordarme ✅)  → memoria + SQLite (user+pass)
// LOGIN NORMAL (recordarme ☐)  → memoria solo
// LOGIN GOOGLE (siempre)        → memoria + SQLite (email)
// SPLASH                        → detecta tipo → re-login correcto
// LOGOUT                        → limpia memoria + SQLite
// ============================================================

import 'package:app_crm/core/database/models/user_model.dart';
import 'package:app_crm/core/network/api_client.dart';
import 'package:app_crm/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:app_crm/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:app_crm/features/auth/data/models/session_model.dart';
import 'package:app_crm/features/auth/domain/entities/session_entity.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final AuthLocalDatasource _local;
  final AuthRemoteDatasource _remote;

  UserModel? _currentUser;

  AuthRepository({
    required AuthLocalDatasource local,
    required AuthRemoteDatasource remote,
  }) : _local = local,
       _remote = remote;

  @override
  UserModel? get currentUser => _currentUser;

  // ── LOGIN NORMAL ─────────────────────────────────────────

  @override
  Future<UserModel> login({
    required String username,
    required String password,
    bool rememberSession = false,
  }) async {
    final user = await _remote.login(username: username, password: password);
    _currentUser = user;
    ApiClient().setToken(user.token);

    if (rememberSession) {
      await _local.saveSession(
        SessionModel(
          loginType: LoginType.credentials,
          username: username,
          password: password,
          expiresAt: DateTime.now().add(const Duration(days: 30)),
        ),
      );
    }

    return _currentUser!;
  }

  // ── LOGIN GOOGLE ─────────────────────────────────────────

  @override
  Future<UserModel> loginWithGoogle({required String email}) async {
    final user = await _remote.loginWithGoogle(email: email);
    _currentUser = user;
    ApiClient().setToken(user.token);

    // Google siempre guarda en SQLite sin importar el checkbox
    await _local.saveSession(
      SessionModel(
        loginType: LoginType.google,
        email: email,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
    );

    return _currentUser!;
  }

  // ── SPLASH ───────────────────────────────────────────────

  @override
  Future<UserModel?> tryRestoreSession() async {
    if (_currentUser != null) return _currentUser;

    final session = await _local.getStoredSession();
    if (session == null) return null;

    final entity = session.toEntity();
    if (entity.isExpired) {
      await _local.clearSession();
      return null;
    }

    // Detecta el tipo y re-autentica con el método correcto
    if (entity.isGoogle) {
      return loginWithGoogle(email: entity.email!);
    } else {
      return login(
        username: entity.username!,
        password: entity.password!,
        rememberSession: true,
      );
    }
  }

  // ── LOGOUT ───────────────────────────────────────────────

  @override
  Future<void> logout() async {
    _currentUser = null;
    ApiClient().clearToken();
    await _local.clearSession();
  }
}
