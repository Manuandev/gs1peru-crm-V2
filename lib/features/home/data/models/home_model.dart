// lib/features/home/data/models/home_model.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeModel extends Home {
  const HomeModel({
    required super.totLeadsNuevos,
    required super.totLeadsDesarrollo,
    required super.totPropuestas,
    required super.totSeguimientos,
    required super.totCobranza,
    required super.totConversaciones,
    required super.totNotificaciones,
    required super.totSolicitudesSinValidar,
    required super.totSeguimientosActivos,
    required super.prioridades,
    required super.prospectos,
    required super.asesores,
  });

  /// Parsea la respuesta completa del SP.
  ///
  /// Formato esperado:
  /// ```
  /// totConv¦totProsp¦totProp¦totCobr¯priori1_f0¦f1¦...¬priori2_f0¦f1¦...
  /// ```
  /// - `¯` (sepListas) separa totales de la lista de prioridades
  /// - `¦` (sepCampos) separa cada campo
  /// - `¬` (sepRegistros) separa cada prioridad
  static HomeModel parse(String rawResponse) {
    // 1) Separar totales de prioridades por '¯'
    final partes = rawResponse.split(AppConstants.sepListas);
    final totalesRaw = partes.isNotEmpty ? partes[0] : '';
    final prioridadesRaw = partes.length > 1 ? partes[1] : '';
    final prospectosRaw = partes.length > 2 ? partes[2] : '';
    final asesoresRaw = partes.length > 3 ? partes[3] : '';

    // 2) Parsear totales
    final c = totalesRaw.split(AppConstants.sepCampos);

    // 3) Parsear listas
    final prioridades = prioridadesRaw.trim().isEmpty
        ? <PrioridadHomeModel>[]
        : PrioridadHomeModel.parseList(prioridadesRaw);

    final prospectos = prospectosRaw.trim().isEmpty
        ? <ProspectoHomeModel>[]
        : ProspectoHomeModel.parseList(prospectosRaw);

    final asesores = asesoresRaw.trim().isEmpty
        ? <AsesorHomeModel>[]
        : AsesorHomeModel.parseList(asesoresRaw);

    return HomeModel(
      totLeadsNuevos: ParseUtils.toInt(c, 0),
      totLeadsDesarrollo: ParseUtils.toInt(c, 1),
      totPropuestas: ParseUtils.toInt(c, 2),
      totSeguimientos: ParseUtils.toInt(c, 3),
      totCobranza: ParseUtils.toInt(c, 4),
      totConversaciones: ParseUtils.toInt(c, 5),
      totNotificaciones: ParseUtils.toInt(c, 6),
      totSolicitudesSinValidar: ParseUtils.toInt(c, 7),
      totSeguimientosActivos: ParseUtils.toInt(c, 8),
      prioridades: prioridades,
      prospectos: prospectos,
      asesores: asesores,
    );
  }
}
