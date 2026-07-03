// lib/core/models/configuracion_item.dart

import 'package:app_crm/core/index_core.dart';

/// Códigos de grupo (ID_CONFIG) y de opción de la tabla T_CONFIGURACION.
/// Agregar aquí cada vez que se sume un grupo nuevo, nunca hardcodear el código.
class ConfiguracionKeys {
  ConfiguracionKeys._();

  // TDE — Tiempo de espera / chat
  static const String tiempoEspera = 'TDE';
  static const int idTiempoChatAbierto = 1;

  // TLA — Tipo de login en app
  static const String tipoLogin = 'TLA';
  static const int idLoginGoogle = 1;
  static const int idLoginCredenciales = 2;
  static const int idLoginAmbos = 3;
}

/// Una fila de la tabla T_CONFIGURACION.
/// Por grupo ([idConfig]), el registro con [id] == 0 es el encabezado
/// (solo descriptivo) y los registros con [id] > 0 son las opciones/valores.
class ConfiguracionItem {
  final String idConfig;
  final int id;
  final String desCorta;
  final String desLarga;
  final String? valor1;
  final String? valor2;
  final String? valor3;
  final String? valor4;
  final String? valor5;

  const ConfiguracionItem({
    required this.idConfig,
    required this.id,
    required this.desCorta,
    required this.desLarga,
    this.valor1,
    this.valor2,
    this.valor3,
    this.valor4,
    this.valor5,
  });

  /// Formato (task 'CA' del SP de listas):
  /// ID_CONFIG¦ID¦DES_CORTA¦DES_LARGA¦VALOR_1¦VALOR_2¦VALOR_3¦VALOR_4¦VALOR_5
  /// El SP ya filtra IB_ACTIVO = 1 en el WHERE, por eso no viaja como campo.
  factory ConfiguracionItem.fromRawString(String raw) {
    final c = ParseUtils.campos(raw, AppConstants.sepCampos);
    return ConfiguracionItem(
      idConfig: ParseUtils.str(c, 0),
      id: ParseUtils.toInt(c, 1),
      desCorta: ParseUtils.str(c, 2),
      desLarga: ParseUtils.str(c, 3),
      valor1: ParseUtils.strNullable(c, 4),
      valor2: ParseUtils.strNullable(c, 5),
      valor3: ParseUtils.strNullable(c, 6),
      valor4: ParseUtils.strNullable(c, 7),
      valor5: ParseUtils.strNullable(c, 8),
    );
  }

  static List<ConfiguracionItem> parseList(String rawResponse) {
    if (rawResponse.trim().isEmpty) return [];
    return rawResponse
        .split(AppConstants.sepRegistros)
        .where((r) => r.trim().isNotEmpty)
        .map(ConfiguracionItem.fromRawString)
        .toList();
  }
}

/// Opción de login habilitada para la app, según el grupo TLA.
enum TipoLoginApp {
  google(ConfiguracionKeys.idLoginGoogle),
  credenciales(ConfiguracionKeys.idLoginCredenciales),
  ambos(ConfiguracionKeys.idLoginAmbos);

  final int id;
  const TipoLoginApp(this.id);

  static TipoLoginApp fromId(int id) => TipoLoginApp.values.firstWhere(
    (e) => e.id == id,
    orElse: () => TipoLoginApp.credenciales,
  );

  bool get mostrarGoogle => this == google || this == ambos;
  bool get mostrarCredenciales => this == credenciales || this == ambos;
}
