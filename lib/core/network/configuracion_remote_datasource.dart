// lib/core/network/configuracion_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';

/// Datasource de configuración global de la app.
///
/// TODO: eliminar el mock y conectar al SP real siguiendo el mismo patrón
/// que CatalogsRemoteDatasource:
///
/// 1. Agregar la constante del endpoint en ApiConstants:
///    static const String urlConfiguracion = '$baseUrl/api/Configuracion/LST';
///
/// 2. Construir el body con los separadores estándar:
///    final body = '${AppConstants.sepListas}CONFIGURACION';
///
/// 3. Llamar al endpoint:
///    final result = await ApiClient().postSafe(ApiConstants.urlConfiguracion, body);
///
/// 4. Parsear la respuesta pipe-delimitada con ParseUtils:
///    El SP devuelve un único registro con AppConstants.sepCampos como delimitador.
///    Formato esperado de la respuesta cruda:
///    "false¦1.0.0¦Bienvenido a GS1 Perú CRM¦true¦https://soporte.gs1peru.org.pe"
///    Campos en orden: mantenimiento¦versionMinima¦mensajeBienvenida¦permitirRegistro¦urlSoporte
///
///    Ejemplo de parseo:
///    case ApiSuccess(:final data):
///      final campos = data.split(AppConstants.sepCampos);
///      return AppConfiguracion(
///        mantenimiento:      campos[0] == 'true',
///        versionMinima:      campos[1],
///        mensajeBienvenida:  campos[2],
///        permitirRegistro:   campos[3] == 'true',
///        urlSoporte:         campos[4],
///      );
class ConfiguracionRemoteDatasource {
  /// Obtiene la configuración global desde el backend.
  /// Por ahora retorna datos mockeados con un delay simulado de red.
  Future<AppConfiguracion> obtenerConfiguracion() async {
    // TODO: reemplazar con la llamada real al SP
    await Future.delayed(const Duration(seconds: 1));

    return const AppConfiguracion(
      mantenimiento: false,
      versionMinima: '1.0.0',
      mensajeBienvenida: '¡Bienvenido a GS1 Perú CRM!',
      permitirRegistro: true,
      urlSoporte: 'https://soporte.gs1peru.org.pe',
    );
  }
}
