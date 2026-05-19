// lib/features/home/presentation/bloc/drawer/drawer_event.dart

abstract class DrawerEvent {}

/// El drawer se abrió → cargar datos del usuario
class DrawerStarted extends DrawerEvent {}

/// Actualizar badges (sin recargar todo)
class DrawerBadgesUpdated extends DrawerEvent {
  final int? conversaciones;
  // final int? pendingReminders;
  // final int? newLeads;
  final int? prospectos;
  final int? propuestas;
  final int? cobranzas;

  DrawerBadgesUpdated({
    this.conversaciones,
    this.prospectos,
    this.propuestas,
    this.cobranzas,
  });
}
