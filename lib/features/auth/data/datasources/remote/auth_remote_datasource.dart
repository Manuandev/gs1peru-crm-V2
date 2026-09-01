// lib/features/auth/data/datasources/remote/auth_remote_datasource.dart
// ============================================================
// Llama a la API y retorna UserModel con todos los datos.
// ============================================================

import 'package:app_crm/core/index_core.dart';

class AuthRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final String body = await DeviceInfoService().buildLoginBody(
      username: username,
      password: password,
    );

    final result = await _api.postSafe(ApiConstants.urlLogin, body);

    return switch (result) {
      ApiSuccess(:final data) => UserModel.fromRawString(data),
      ApiEmpty() => throw const AppException('Credenciales incorrectas.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<UserModel> loginWithGoogle({
    required String accessToken,
    required String correo,
  }) async {
    final info = await DeviceInfoService.getInfoConTimeout();

    final body = [
      accessToken,
      correo,
      info['ip_local'],
      info['coordenadas'],
      info['so'],
      info['modelo'],
      info['so_version'],
      info['pais_codigo'],
      info['region'],
      info['ciudad'],
      AppConstants.version,
    ].join(AppConstants.sepCampos);

    final resultado = await _api.postSafe(ApiConstants.urlLoginGoogle, body);

    return switch (resultado) {
      ApiSuccess(:final data) => _parsearRespuestaGoogle(data),
      ApiEmpty() => throw const AppException('Error al conectar con Google'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),  
    };
  }

  UserModel _parsearRespuestaGoogle(String data) {
    if (data.isEmpty) throw const AppException('Error al conectar con Google');
    try {
      return UserModel.fromRawString(data);
    } on FormatException catch (e) {
      throw AppException(e.message);
    }
  }

  // Task 'O' — dbo.CSV_SYSMUSER01_LOGOUT_APP. Invalida el TOKEN activo del
  // usuario (busca por TIPO_USER+COD_USER+NAVEGADOR, no por el valor del
  // token en sí) y limpia el token FCM guardado en SYSMUSER01_FCM. Best
  // effort — si falla (sin internet, servidor caído), no debe impedir que
  // el logout local siga adelante (ver AuthRepositoryImpl.logout()).
  //
  // [codUser] — opcional, default SessionService().codUser (logout normal,
  // con la sesión ya restaurada a memoria). Se puede pasar explícito para
  // el caso Splash: cuando se fuerza un logout SIN haber restaurado la
  // sesión (ej. actualización obligatoria pendiente), SessionService sigue
  // vacío — ahí el caller lee el codUser directo de la SessionModel
  // guardada en SQLite (persistido en cada login, ver auth/CLAUDE.md).
  Future<void> logout({String? codUser}) async {
    final id = codUser ?? _session.codUser;
    if (id.isEmpty) return; // nada que invalidar sin saber de quién

    final info = await DeviceInfoService.getInfoConTimeout();

    final body =
        '${[
          'PER',
          info['navegador'],
          id,
          info['ip_local'],
          info['coordenadas'],
        ].join(camp)}${sep}O';

    await _api.postSafe(ApiConstants.urlLogout, body);
  }

  Future<CrudResult> recuperarClave(String correo) async {
    final ip = await _deviceInfo.getLocalIp();

    final String body =
        '${[correo, _session.codUser, ip].join(camp)}'
        '${sep}R';

    final result = await _api.postSafe(ApiConstants.urlRecuperarUsuario, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }
}
