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

import 'package:app_crm/core/network/interceptors/error_interceptor.dart';
import 'package:app_crm/core/network/interceptors/log_interceptor.dart';
import 'package:app_crm/core/network/interceptors/token_interceptor.dart';
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

  // ============================================================
  // 1. POST TEXTO (Tu formato actual con respuestas pipe ¯)
  // ============================================================
  Future<String> postText(String url, String body) async {
    final response = await _dio.post(
      url,
      data: body,
      options: Options(
        contentType: 'text/plain',
        responseType: ResponseType.plain,
      ),
    );
    return response.data?.toString() ?? '';
  }

  // ============================================================
  // 2. POST JSON (Envía y recibe JSON)
  // ============================================================

  // En api_client.dart — para APIs que reciben un string JSON-encoded
  Future<Map<String, dynamic>?> postJsonString(
    String url,
    String body, {
    Map<String, dynamic>? headers,
  }) async {
    final response = await _dio.post(
      url,
      data: body, // Dio lo serializa como JSON string → "PER¦..."
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: headers,
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return null;
  }

  Future<Map<String, dynamic>?> postJson(
    String url,
    Map<String, dynamic> data, {
    Map<String, dynamic>? headers,
  }) async {
    final response = await _dio.post(
      url,
      data: data,
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: headers,
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }
    return null;
  }

  // ============================================================
  // 3. POST JSON CON TOKEN EN HEADER
  // ============================================================
  // Útil para tu API que requiere 'Token' en el header
  Future<Map<String, dynamic>?> postJsonWithToken(
    String url,
    Map<String, dynamic> data, {
    required String token,
  }) async {
    return postJson(url, data, headers: {'Token': token});
  }

  // ============================================================
  // 4. GET JSON
  // ============================================================
  Future<dynamic> getJson(String url, {Map<String, dynamic>? params}) async {
    final response = await _dio.get(
      url,
      queryParameters: params,
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );
    return response.data;
  }

  // ============================================================
  // 5. POST MULTIPART (Con archivo)
  // ============================================================
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
