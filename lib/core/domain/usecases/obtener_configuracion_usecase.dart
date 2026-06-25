// lib/core/domain/usecases/obtener_configuracion_usecase.dart

import 'package:app_crm/core/index_core.dart';

class ObtenerConfiguracionUseCase {
  final ConfiguracionRepository repository;
  const ObtenerConfiguracionUseCase(this.repository);

  Future<AppConfiguracion> call() => repository.obtenerConfiguracion();
}
