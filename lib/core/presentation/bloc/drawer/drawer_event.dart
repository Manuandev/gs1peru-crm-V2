// lib/core/presentation/bloc/drawer/drawer_event.dart

abstract class DrawerEvent {}

/// El drawer se abrió → cargar datos del usuario
class DrawerStarted extends DrawerEvent {}

/// Actualizar badges (sin recargar todo)
class DrawerBadgesUpdated extends DrawerEvent {
  final int? conversaciones;
  final int? seguimientos;
  final int? cobranza;
  final int? solicitudes;

  DrawerBadgesUpdated({
    this.conversaciones,
    this.seguimientos,
    this.cobranza,
    this.solicitudes,
  });
}
