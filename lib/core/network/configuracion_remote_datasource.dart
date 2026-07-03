// lib/core/network/configuracion_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';

/// Datasource de configuración global de la app.
/// Mismo SP de listas (CRM.CSV_LISTAS_LST_APP), task 'CA' — ver rama
/// ELSE IF(@L_TASK = 'CA') del SP para el detalle del SELECT.
class ConfiguracionRemoteDatasource {
  final ApiClient _api = ApiClient();

  final sep = AppConstants.sepListas;

  Future<AppConfiguracion> obtenerConfiguracion() async {
    final String body = '${sep}CA';

    final result = await _api.postSafe(ApiConstants.urlListasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => AppConfiguracion.parse(data),
      ApiEmpty() => const AppConfiguracion(items: []),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
