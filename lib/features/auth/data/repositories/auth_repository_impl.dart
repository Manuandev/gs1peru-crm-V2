// lib/features/auth/data/repositories/auth_repository_impl.dart
// ============================================================
// LOGIN NORMAL (recordarme ✅)  → memoria + SQLite (user+pass)
// LOGIN NORMAL (recordarme ☐)  → memoria solo
// LOGIN GOOGLE (siempre)        → memoria + SQLite (email)
// SPLASH                        → detecta tipo → re-login correcto
// LOGOUT                        → limpia memoria + SQLite
// ============================================================

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/auth/index_auth.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource _local;
  final AuthRemoteDatasource _remote;

  UserModel? _currentUser;

  AuthRepositoryImpl({
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
    SessionService().setUser(user);

    await _local.saveSession(
      SessionModel(
        loginType: LoginType.credentials,
        username: username,
        password: password,
        rememberMe: rememberSession,
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      ),
    );

    return _currentUser!;
  }

  // ── LOGIN GOOGLE ─────────────────────────────────────────

  @override
  Future<UserModel> loginWithGoogle({
    required String accessToken,
    required String correo,
  }) async {
    final user = await _remote.loginWithGoogle(
      accessToken: accessToken,
      correo: correo,
    );
    _currentUser = user;
    ApiClient().setToken(user.token);
    SessionService().setUser(user);

    // Google siempre persiste en SQLite — el correo es suficiente para re-auth
    await _local.saveSession(
      SessionModel(
        loginType: LoginType.google,
        email: correo,
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

    if (!entity.rememberMe && !entity.isGoogle) {
      await _local.clearSession();
      throw SessionNotRememberedException(entity.username ?? '', entity.password ?? '');
    }

    // Detecta el tipo y re-autentica con el método correcto
    if (entity.isGoogle) {
      // Los access tokens de Google son de corta vida y no se persisten.
      // Limpiar sesión → LoginPage → usuario toca "Ingresar con Google".
      await _local.clearSession();
      return null;
    } else {
      return login(
        username: entity.username!,
        password: entity.password!,
        rememberSession: true,
      );
    }
  }

  // ── RECUPERAR CLAVE ──────────────────────────────────────

  @override
  Future<void> recuperarClave(String correo) =>
      _remote.recuperarClave(correo);

  // ── LOGOUT ───────────────────────────────────────────────

  @override
  Future<void> logout() async {
    _currentUser = null;
    ApiClient().clearToken();
    SessionService().clear();
    await _local.clearSession();
  }
}
