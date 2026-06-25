// lib/core/domain/entities/app_configuracion.dart

import 'package:app_crm/index_dependencies.dart';

/// Configuración global de la app obtenida del backend en cada inicio de sesión.
/// Contiene parámetros que controlan el comportamiento de la app sin necesidad
/// de publicar una nueva versión.
class AppConfiguracion extends Equatable {
  final bool mantenimiento;
  final String versionMinima;
  final String mensajeBienvenida;
  final bool permitirRegistro;
  final String urlSoporte;

  const AppConfiguracion({
    required this.mantenimiento,
    required this.versionMinima,
    required this.mensajeBienvenida,
    required this.permitirRegistro,
    required this.urlSoporte,
  });

  @override
  List<Object?> get props => [
    mantenimiento,
    versionMinima,
    mensajeBienvenida,
    permitirRegistro,
    urlSoporte,
  ];
}
