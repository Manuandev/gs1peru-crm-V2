// lib/features/auth/data/datasources/remote/auth_remote_datasource.dart
// ============================================================
// Llama a la API y retorna UserModel con todos los datos.
// ============================================================

import 'dart:convert';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/core/network/api_result.dart';

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

  Future<UserModel> loginWithGoogle({required String email}) async {
    final result = await _api.postSafe(
      ApiConstants.urlLoginGoogle,
      json.encode(email),
    );

    return switch (result) {
      ApiSuccess(:final data) => UserModel.fromRawString(data),
      ApiEmpty() => throw const AppException('Usuario no encontrado.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
