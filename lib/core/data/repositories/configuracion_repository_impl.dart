// lib/core/data/repositories/configuracion_repository_impl.dart

import 'package:app_crm/core/index_core.dart';

class ConfiguracionRepositoryImpl implements ConfiguracionRepository {
  final ConfiguracionRemoteDatasource _remote;

  ConfiguracionRepositoryImpl(this._remote);

  @override
  Future<AppConfiguracion> obtenerConfiguracion() =>
      _remote.obtenerConfiguracion();
}
