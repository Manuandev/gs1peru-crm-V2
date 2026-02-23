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

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:app_crm/core/network/api_result.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  String _token = '';

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    // ✅ Interceptor que inyecta el token en el body automáticamente
    _dio.interceptors.add(_TokenBodyInterceptor(this));
    // Log en debug — quitar en producción si quieres
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
    // Al final de ApiClient._internal()
    _dio.interceptors.add(_CleanResponseInterceptor());
  }

  void setToken(String token) => _token = token;
  void clearToken() => _token = '';

  // ============================================================
  // 1. POST TEXTO (Tu formato actual con respuestas pipe ¯)
  // ============================================================
  Future<String> postText(String url, String body) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          contentType: 'text/plain',
          responseType: ResponseType.plain,
        ),
      );
      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw const SocketException('Sin conexión a internet');
      }
      return '';
    }
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
    try {
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw const SocketException('Sin conexión a internet');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const SocketException('Tiempo de espera agotado');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> postJson(
    String url,
    Map<String, dynamic> data, {
    Map<String, dynamic>? headers,
  }) async {
    try {
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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw const SocketException('Sin conexión a internet');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const SocketException('Tiempo de espera agotado');
      }
      return null;
    }
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
    try {
      final response = await _dio.get(
        url,
        queryParameters: params,
        options: Options(
          contentType: 'application/json',
          responseType: ResponseType.json,
        ),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw const SocketException('Sin conexión a internet');
      }
      return null;
    }
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
    try {
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
    } catch (e) {
      return '';
    }
  }

  // ============================================================
  // 6. PROCESAR RESPUESTA TEXTO (Tu formato con ¯)
  // ============================================================
  ApiResult processApiResponse(String response) {
    if (response.isEmpty) {
      return ApiResult(ok: false, code: 'ERR', message: 'Error de conexión');
    }

    final partes = response.split('¯');

    if (partes.length > 1) {
      return ApiResult(
        ok: partes[0] == 'OK',
        code: partes[0],
        message: partes[1],
      );
    }

    return ApiResult(ok: false, code: 'ERR', message: 'Error desconocido');
  }

  // En ApiClient — envía JSON, recibe cadena cruda
  Future<String> postJsonGetText(
    String url,
    String body, {
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(
          contentType: 'application/json',
          responseType: ResponseType.plain,
          headers: headers,
        ),
      );
      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        throw const SocketException('Sin conexión a internet');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const SocketException('Tiempo de espera agotado');
      }
      return '';
    }
  }
}

// La clase — puede ir al final del mismo archivo
class _TokenBodyInterceptor extends Interceptor {
  final ApiClient _client;
  _TokenBodyInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data is String) {
      // 1. Agrega el token al string plano
      final withToken = '${_client._token}¯${options.data}';
      // 2. Ahora lo convierte a JSON string (agrega las comillas)
      options.data = json.encode(withToken);
    }
    handler.next(options);
  }
}

// Interceptor que limpia las comillas que mete ASP.NET
class _CleanResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      response.data = (response.data as String).replaceAll('"', '').trim();
    }
    handler.next(response);
  }
}
