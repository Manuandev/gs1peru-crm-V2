import 'dart:io';

import 'package:app_crm/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return handler.reject(
          _wrap(err, const NetworkException('Tiempo de espera agotado.')),
        );

      case DioExceptionType.connectionError:
        return handler.reject(
          _wrap(err, const SocketException('Sin conexión a internet.')),
        );

      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        return handler.reject(
          _wrap(err, NetworkException('Error del servidor ($status).')),
        );

      case DioExceptionType.unknown:
        if (err.error is SocketException) {
          return handler.reject(
            _wrap(err, const SocketException('Sin conexión a internet.')),
          );
        }
        return handler.reject(
          _wrap(err, NetworkException('Error inesperado: ${err.message}')),
        );

      default:
        return handler.next(err); // dejar pasar el resto
    }
  }

  /// Envuelve el error original conservando request/response para el log
  DioException _wrap(DioException original, Exception newError) {
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      error: newError,
      type: original.type,
    );
  }
}