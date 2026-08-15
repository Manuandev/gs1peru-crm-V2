// lib/features/auth/data/repositories/auth_repository_impl.dart
// ============================================================
// LOGIN NORMAL (recordarme ✅)  → memoria + SQLite (user+pass)
// LOGIN NORMAL (recordarme ☐)  → memoria solo
// LOGIN GOOGLE (siempre)        → memoria + SQLite (email)
// SPLASH                        → detecta tipo → re-login correcto
// LOGOUT                        → limpia memoria + SQLite
// ============================================================

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';

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
        codUser: user.codUser,
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
    // Dispositivo con varias cuentas de Google sincronizadas — si ya había
    // una sesión Google guardada de OTRA cuenta (ej. Manuel), avisa al
    // backend que esa sesión vieja quedó desconectada ANTES de continuar
    // con la nueva (Antonio). Awaited a propósito, ver método más abajo.
    await _cerrarSesionGoogleAnteriorSiCambiaDeCuenta(correo);

    final user = await _remote.loginWithGoogle(
      accessToken: accessToken,
      correo: correo,
    );
    _currentUser = user;
    ApiClient().setToken(user.token);
    SessionService().setUser(user);

    // Google persiste email + idToken en SQLite — el email se usa para
    // verificar la cuenta al restaurar sesión en el Splash (ver
    // _reautenticarGoogleSilenciosamente()); el idToken en sí ya no se
    // reutiliza para eso (dura ~1h, casi siempre está vencido al volver a
    // abrir la app), solo queda guardado por si hiciera falta a futuro.
    await _local.saveSession(
      SessionModel(
        loginType: LoginType.google,
        email:     correo,
        idToken:   accessToken,
        codUser:   user.codUser,
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
      _invalidarTokenRemoto(entity);
      await _local.clearSession();
      return null;
    }

    if (!entity.rememberMe && !entity.isGoogle) {
      _invalidarTokenRemoto(entity);
      await _local.clearSession();
      throw SessionNotRememberedException(entity.username ?? '', entity.password ?? '');
    }

    // Detecta el tipo y re-autentica con el método correcto
    if (entity.isGoogle) {
      // El idToken guardado en SQLite dura ~1h (lo emite Google, no
      // nosotros) — reusarlo tal cual después de esa hora siempre falla.
      // En vez de eso, se pide uno FRESCO en silencio contra la sesión
      // nativa de Google del dispositivo (sin mostrar ningún diálogo) —
      // ver _reautenticarGoogleSilenciosamente() y auth/CLAUDE.md.
      final cuenta = await _reautenticarGoogleSilenciosamente(entity.email);
      if (cuenta == null) {
        _invalidarTokenRemoto(entity);
        await _local.clearSession();
        return null;
      }
      try {
        return await loginWithGoogle(
          accessToken: cuenta.authentication.idToken!,
          correo:      cuenta.email,
        );
      } on AppException {
        _invalidarTokenRemoto(entity);
        await _local.clearSession();
        return null;
      }
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
  Future<CrudResult> recuperarClave(String correo) =>
      _remote.recuperarClave(correo);

  // ── LOGOUT ───────────────────────────────────────────────

  @override
  Future<void> logout() async {
    // Antes de limpiar memoria/token — el SP de logout necesita el
    // codUser (SessionService) y el token (ApiClient) todavía activos.
    await _remote.logout();

    _currentUser = null;
    ApiClient().clearToken();
    SessionService().clear();
    await _local.clearSession();
  }

  /// Si ya hay una sesión Google guardada en SQLite de OTRA cuenta —
  /// dispositivo con varias cuentas sincronizadas, el usuario entra con una
  /// distinta a la que tenía guardada (desde el selector nativo, silencioso
  /// o vía el botón "Iniciar con Google") — invalida el TOKEN de la cuenta
  /// vieja en el backend ANTES de intentar el login nuevo. A diferencia de
  /// [_invalidarTokenRemoto] (fire-and-forget), acá se espera la respuesta a
  /// propósito: si no se espera, el login de la cuenta nueva puede llegar al
  /// backend antes de que termine de procesarse la desconexión de la vieja.
  Future<void> _cerrarSesionGoogleAnteriorSiCambiaDeCuenta(
    String correoNuevo,
  ) async {
    final session = await _local.getStoredSession();
    if (session == null || session.loginType != LoginType.google) return;
    if (session.email == null || session.email == correoNuevo) return;
    await _remote.logout(codUser: session.codUser ?? '');
  }

  /// Pide un idToken de Google fresco SIN interacción del usuario —
  /// `GoogleSignIn.instance.attemptLightweightAuthentication()` restaura la
  /// sesión nativa del SDK en el dispositivo (misma cuenta con la que ya se
  /// hizo `authenticate()` alguna vez) y devuelve un token recién emitido,
  /// evitando que el usuario tenga que volver a tocar "Iniciar con Google"
  /// cada vez que pasa la hora de vida del idToken guardado.
  ///
  /// Retorna `null` si no hay nada que restaurar en silencio — el usuario
  /// cerró sesión de Google en el dispositivo, revocó el acceso, la cuenta
  /// activa ya no coincide con [emailGuardado], o el SDK no devuelve token
  /// — el caller cae al flujo normal (limpiar sesión → Login, ver arriba).
  Future<GoogleSignInAccount?> _reautenticarGoogleSilenciosamente(
    String? emailGuardado,
  ) async {
    try {
      final future = GoogleSignIn.instance.attemptLightweightAuthentication();
      final cuenta = future == null ? null : await future;
      if (cuenta == null) return null;
      if (emailGuardado != null && cuenta.email != emailGuardado) return null;
      if (cuenta.authentication.idToken == null) return null;
      return cuenta;
    } on GoogleSignInException {
      return null;
    }
  }

  /// Invalida el TOKEN en el backend cuando `tryRestoreSession()` fuerza un
  /// cierre de sesión SIN que el usuario haya presionado "Cerrar sesión"
  /// (sesión vencida, no recordada, o token de Google inválido/rechazado) —
  /// en estos casos `SessionService`/`ApiClient` nunca se poblaron (no hubo
  /// re-login exitoso), así que `_remote.logout()` no puede usar su default
  /// (`SessionService().codUser`, vacío acá). Se manda el `codUser`
  /// persistido en la propia `SessionModel` (ver auth/CLAUDE.md) — mismo
  /// dato que ya devuelve el login, sea por credenciales o Google.
  /// Fire-and-forget (`unawaited`) y best effort — `_remote.logout()` nunca
  /// lanza excepción (ver AuthRemoteDatasource.logout()), así que no hay
  /// nada que atrapar; no debe demorar el flujo de Splash/restauración.
  void _invalidarTokenRemoto(SessionEntity entity) {
    final id = entity.codUser ?? entity.username ?? '';
    if (id.isEmpty) return;
    unawaited(_remote.logout(codUser: id));
  }
}
