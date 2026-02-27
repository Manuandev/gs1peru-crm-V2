import 'dart:convert';
import 'package:app_crm/core/network/api_client.dart';
import 'package:dio/dio.dart';

/// Inyecta el token en el body antes de enviar la request.
/// Formato: "TOKEN¯datos" → json.encode() → "\"TOKEN¯datos\""
class TokenBodyInterceptor extends Interceptor {
  final ApiClient _client;

  TokenBodyInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data is String) {
      options.data = json.encode('${_client.token}¯${options.data}');
    }
    handler.next(options);
  }
}