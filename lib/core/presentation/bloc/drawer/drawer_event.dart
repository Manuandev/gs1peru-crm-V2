// lib/features/home/presentation/bloc/drawer/drawer_event.dart

abstract class DrawerEvent {}

/// El drawer se abrió → cargar datos del usuario
class DrawerStarted extends DrawerEvent {}

/// Actualizar badges (sin recargar todo)
class DrawerBadgesUpdated extends DrawerEvent {
  final int? unreadChats;
  final int? pendingReminders;
  final int? newLeads;

  DrawerBadgesUpdated({
    this.unreadChats ,
    this.pendingReminders ,
    this.newLeads ,
  });
}
