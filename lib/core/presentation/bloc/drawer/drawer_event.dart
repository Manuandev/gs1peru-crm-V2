// lib/core/presentation/bloc/drawer/drawer_event.dart

abstract class DrawerEvent {}

/// El drawer se abrió → cargar datos del usuario
class DrawerStarted extends DrawerEvent {}

/// Actualizar badges (sin recargar todo)
class DrawerBadgesUpdated extends DrawerEvent {
  final int? conversaciones;
  final int? prospectos;
  final int? cobranza;

  DrawerBadgesUpdated({
    this.conversaciones,
    this.prospectos,
    this.cobranza,
  });
}
