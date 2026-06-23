// lib/features/auth/data/datasources/remote/auth_remote_datasource.dart
// ============================================================
// Llama a la API y retorna UserModel con todos los datos.
// ============================================================

import 'package:app_crm/core/index_core.dart';

class AuthRemoteDatasource {
  final ApiClient _api = ApiClient();

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

  Future<void> recuperarClave(String correo) async {
    // TODO(backend): llamar al endpoint de recuperación de clave cuando el
    // equipo defina la URL y parámetros exactos.
    // Ejemplo: POST a ApiConstants.urlRecuperarClave con body {correo: correo}
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<UserModel> loginWithGoogle({
    required String accessToken,
    required String correo,
  }) async {
    final info = await DeviceInfoService.getInfoConTimeout();
    final fecha = _formatearFecha(DateTime.now());

    final body = [
      accessToken,
      correo,
      info['ip_local'],
      info['coordenadas'],
      info['pais_codigo'],
      info['region'],
      info['ciudad'],
      fecha,
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
      // El SP retorna ERROR¯<mensaje descriptivo> — fromRawString lo convierte
      // en FormatException(mensaje). Lo reempaquetamos como AppException para
      // que el bloc lo muestre directamente sin prefijo "Error inesperado".
      throw AppException(e.message);
    }
  }

  String _formatearFecha(DateTime fecha) {
    final y = fecha.year.toString().padLeft(4, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final d = fecha.day.toString().padLeft(2, '0');
    final h = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    final s = fecha.second.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min:$s.000';
  }
}
