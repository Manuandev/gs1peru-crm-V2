// lib/features/home/domain/entities/home.dart
import 'package:app_crm/features/home/index_home.dart';

class Home {
  final int totLeadsNuevos;
  final int totLeadsDesarrollo;
  final int totPropuestas;
  final int totSeguimientos;
  final int totCobranza;
  final int totConversaciones;
  final int totNotificaciones;
  final int totSolicitudesSinValidar;

  final List<PrioridadHome> prioridades;
  final List<ProspectoHome> prospectos;
  final List<AsesorHome> asesores;

  const Home({
    required this.totLeadsNuevos,
    required this.totLeadsDesarrollo,
    required this.totPropuestas,
    required this.totSeguimientos,
    required this.totCobranza,
    required this.totConversaciones,
    required this.totNotificaciones,
    required this.totSolicitudesSinValidar,
    required this.prioridades,
    required this.prospectos,
    required this.asesores,
  });

  Home copyWith({
    int? totLeadsNuevos,
    int? totLeadsDesarrollo,
    int? totPropuestas,
    int? totSeguimientos,
    int? totCobranza,
    int? totConversaciones,
    int? totNotificaciones,
    int? totSolicitudesSinValidar,
    List<PrioridadHome>? prioridades,
    List<ProspectoHome>? prospectos,
    List<AsesorHome>? asesores,
  }) {
    return Home(
      totLeadsNuevos: totLeadsNuevos ?? this.totLeadsNuevos,
      totLeadsDesarrollo: totLeadsDesarrollo ?? this.totLeadsDesarrollo,
      totPropuestas: totPropuestas ?? this.totPropuestas,
      totSeguimientos: totSeguimientos ?? this.totSeguimientos,
      totCobranza: totCobranza ?? this.totCobranza,
      totConversaciones: totConversaciones ?? this.totConversaciones,
      totNotificaciones: totNotificaciones ?? this.totNotificaciones,
      totSolicitudesSinValidar:
          totSolicitudesSinValidar ?? this.totSolicitudesSinValidar,
      prioridades: prioridades ?? this.prioridades,
      prospectos: prospectos ?? this.prospectos,
      asesores: asesores ?? this.asesores,
    );
  }
}
