// lib/features/auth/data/datasources/remote/auth_remote_datasource.dart
// ============================================================
// Llama a la API y retorna UserModel con todos los datos.
// ============================================================

import 'dart:convert';
import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/database/models/user_model.dart';
import 'package:app_crm/core/network/api_client.dart';
import 'package:app_crm/core/services/device_info_service.dart';

class AuthRemoteDatasource {
  final ApiClient _api = ApiClient();

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // ✓ Datos reales del dispositivo en tiempo real
    final String body = await DeviceInfoService().buildLoginBody(
      username: username,
      password: password,
    );

    final response = await _api.postJsonString(
      ApiConstants.urlLogin,
      json.encode(body),
      headers: {'Token': 'fcff'},
    );

    if (response == null) {
      throw const NetworkException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    if (response['Token'] != null) {
      return UserModel.fromJson(response);
    }

    throw AuthException(
      response['Mensaje']?.toString() ??
          response['message']?.toString() ??
          'Usuario o contraseña incorrectos',
    );
  }

  Future<UserModel> loginWithGoogle({required String email}) async {
    final response = await _api.postJsonString(
      ApiConstants.urlLoginGoogle, // Todo: agrega esta constante
      json.encode(email),
      headers: {'Token': 'fcff'},
    );

    if (response == null) {
      throw const NetworkException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    if (response['Token'] != null) {
      return UserModel.fromJson(response);
    }

    throw AuthException(
      response['Mensaje']?.toString() ?? 'Correo no autorizado',
    );
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}
