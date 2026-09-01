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

import 'package:flutter/foundation.dart';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

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
        receiveTimeout: const Duration(minutes: 3),
      ),
    );

    _dio.interceptors.addAll([
      // Primero — si hay una actualización pendiente y es un endpoint CUD,
      // corta acá mismo, antes de gastar tiempo armando el body con token.
      UpdateRequiredInterceptor(),
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

    // No sobreescribir contentType — Dio lo construye automáticamente con el
    // boundary correcto cuando el body es FormData.
    final response = await _dio.post(
      url,
      data: formData,
      options: Options(
        headers: headers,
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
      ),
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

  // Igual que postJsonGetText pero para respuestas binarias (ej. descarga de
  // plantillas Excel) — responseType.bytes evita que Dio intente decodificar
  // la respuesta como texto/JSON.
  Future<List<int>> postJsonGetBytes(String url, String body) async {
    final response = await _dio.post(
      url,
      data: body,
      options: Options(
        contentType: 'application/json',
        responseType: ResponseType.bytes,
        headers: {'Token': _token},
      ),
    );
    return response.data as List<int>;
  }

  // Agrega esto en api_client.dart — debajo de postJsonGetText
  Future<ApiResult<String>> postSafe(String url, String body) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          contentType: 'application/json',
          responseType: ResponseType.plain,
          headers: {'Token': _token},
        ),
      );

      final raw = response.data?.toString() ?? '';
      if (raw.isEmpty) return const ApiEmpty();
      return ApiSuccess(raw);
    } on DioException catch (e) {
      final inner = e.error;
      if (inner is AppException) return ApiError(inner.message);
      return ApiError(e.message ?? 'Error desconocido');
    }
  }
}
