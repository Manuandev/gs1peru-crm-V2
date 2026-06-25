// lib/core/domain/repositories/configuracion_repository.dart

import 'package:app_crm/core/index_core.dart';

abstract class ConfiguracionRepository {
  Future<AppConfiguracion> obtenerConfiguracion();
}
