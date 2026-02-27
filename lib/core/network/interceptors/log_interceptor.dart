import 'package:dio/dio.dart';

/// Limpia las comillas extra que agrega ASP.NET en las respuestas.
/// Ejemplo: "\"hola mundo\"" → "hola mundo"
class CleanResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      response.data = (response.data as String).replaceAll('"', '').trim();
    }
    handler.next(response);
  }
}