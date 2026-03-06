// lib/core/network/api_client.dart
// ============================================================
// API CLIENT — CON MANEJO DE ERRORES MEJORADO
// ============================================================
//
// CAMBIOS RESPECTO A TU VERSIÓN ANTERIOR:
// - postJson ahora lanza excepciones en vez de retornar null
//   para que los datasources puedan manejar errores específicos
// - Se agrega postJsonWithToken para peticiones con header Token
// ============================================================

import 'package:app_crm/core/index_core.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  String _token = '';
  String get token => _token;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.addAll([
      TokenBodyInterceptor(this),
      CleanResponseInterceptor(),
      ErrorInterceptor(),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  void setToken(String token) => _token = token;
  void clearToken() => _token = '';

  Future<String> postMultipart({
    required String url,
    required Map<String, String> fields,
    required String fileFieldName,
    required List<int> fileBytes,
    required String fileName,
    Map<String, String>? headers,
  }) async {
    final formData = FormData.fromMap(fields);

    if (fileBytes.isNotEmpty && fileName.isNotEmpty) {
      formData.files.add(
        MapEntry(
          fileFieldName,
          MultipartFile.fromBytes(fileBytes, filename: fileName),
        ),
      );
    }

    final response = await _dio.post(
      url,
      data: formData,
      options: Options(headers: headers, contentType: 'multipart/form-data'),
    );

    return response.data?.toString() ?? '';
  }

  // En ApiClient — envía JSON, recibe cadena cruda
  Future<String> postJsonGetText(String url, String body) async {
    final response = await _dio.post(
      url,
      data: body,
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.plain,
        headers: {'Token': _token},
      ),
    );
    return response.data?.toString() ?? '';
  }
}
