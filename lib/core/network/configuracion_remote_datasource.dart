// lib/core/network/configuracion_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';

/// Datasource de configuración global de la app (tabla T_CONFIGURACION).
///
/// TODO: eliminar el mock y conectar al SP real siguiendo el mismo patrón
/// que CatalogsRemoteDatasource:
///
/// 1. Endpoint (mismo SP de listas, otro código de task — ver ApiConstants.lstListas):
///    static const String urlConfiguracion = '$baseUrl/api/Configuracion/LST';
///
/// 2. Body con los separadores estándar (sin datos adicionales, solo el task):
///    final body = '${AppConstants.sepListas}C';
///
/// 3. Llamar al endpoint:
///    final result = await ApiClient().postSafe(ApiConstants.urlConfiguracion, body);
///
/// 4. El SP devuelve todas las filas activas de T_CONFIGURACION en un solo bloque,
///    ordenadas por ID_CONFIG, ID — registros separados por sepRegistros ('¬'),
///    campos por sepCampos ('¦'):
///
///    SELECT STRING_AGG(
///      CONCAT(ID_CONFIG, '¦', ID, '¦', DES_CORTA, '¦', ISNULL(DES_LARGA,''), '¦',
///             ISNULL(CONVERT(VARCHAR, VALOR_1), ''), '¦', ISNULL(CONVERT(VARCHAR, VALOR_2), ''), '¦',
///             ISNULL(CONVERT(VARCHAR, VALOR_3), ''), '¦', ISNULL(CONVERT(VARCHAR, VALOR_4), ''), '¦',
///             ISNULL(CONVERT(VARCHAR, VALOR_5), ''), '¦', IB_ACTIVO),
///      '¬'
///    ) WITHIN GROUP (ORDER BY ID_CONFIG, ID)
///    FROM T_CONFIGURACION
///    WHERE IB_ACTIVO = 1
///
/// 5. Parsear con el modelo ya listo:
///    case ApiSuccess(:final data): return AppConfiguracion.parse(data);
///    case ApiEmpty(): return const AppConfiguracion(items: []);
class ConfiguracionRemoteDatasource {
  /// Obtiene la configuración global desde el backend.
  /// Por ahora retorna datos mockeados con un delay simulado de red,
  /// con la misma forma que devolverá el SP real (ver TODO arriba).
  Future<AppConfiguracion> obtenerConfiguracion() async {
    // TODO: reemplazar con la llamada real al SP
    await Future.delayed(const Duration(seconds: 1));

    const mockRaw =
        'TDE¦0¦Tiempo de espera¦¦¦¦¦¦¦1¬'
        'TDE¦1¦Tiempo de chat abierto¦¦72.00¦¦¦¦¦1¬'
        'TLA¦0¦Tipo de login en app¦¦¦¦¦¦¦1¬'
        'TLA¦1¦Login con Google¦¦¦¦¦¦0¦1¬'
        'TLA¦2¦Login con credenciales¦¦¦¦¦¦¦1¬'
        'TLA¦3¦Login con credenciales o Google¦¦¦¦¦¦1¦1';

    return AppConfiguracion.parse(mockRaw);
  }
}
