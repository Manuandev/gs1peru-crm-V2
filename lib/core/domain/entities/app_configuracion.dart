// lib/core/domain/entities/app_configuracion.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';

/// Configuración global de la app, agrupada por ID_CONFIG (tabla T_CONFIGURACION).
/// Se obtiene del backend en el splash y contiene parámetros que controlan
/// el comportamiento de la app sin necesidad de publicar una nueva versión.
///
/// Para agregar un grupo nuevo (ID_CONFIG):
/// 1. Agregar sus códigos en [ConfiguracionKeys]
/// 2. Agregar un getter de conveniencia aquí, igual que [tiempoChatAbierto] o [tipoLogin]
class AppConfiguracion extends Equatable {
  final List<ConfiguracionItem> items;

  const AppConfiguracion({required this.items});

  factory AppConfiguracion.parse(String rawResponse) =>
      AppConfiguracion(items: ConfiguracionItem.parseList(rawResponse));

  /// Opciones (id > 0) de un grupo, ya filtradas por activas.
  List<ConfiguracionItem> _opciones(String idConfig) => items
      .where((c) => c.idConfig == idConfig && c.id > 0 && c.activo)
      .toList();

  // ── TDE — Tiempo de espera / chat abierto (minutos) ────────
  double get tiempoChatAbierto {
    final item = _opciones(ConfiguracionKeys.tiempoEspera)
        .where((c) => c.id == ConfiguracionKeys.idTiempoChatAbierto)
        .firstOrNull;
    return double.tryParse(item?.valor1 ?? '') ?? 15.0;
  }

  // ── TLA — Tipo de login habilitado en la app ───────────────
  /// La opción marcada como activa (VALOR_5 == '1'); credenciales por defecto.
  TipoLoginApp get tipoLogin {
    final activa = _opciones(ConfiguracionKeys.tipoLogin)
        .where((c) => c.valor5 == '1')
        .firstOrNull;
    return TipoLoginApp.fromId(activa?.id ?? ConfiguracionKeys.idLoginCredenciales);
  }

  @override
  List<Object?> get props => [items];
}
