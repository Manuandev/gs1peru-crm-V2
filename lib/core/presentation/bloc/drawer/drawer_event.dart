// lib/features/home/presentation/bloc/drawer/drawer_event.dart

abstract class DrawerEvent {}

/// El drawer se abrió → cargar datos del usuario
class DrawerStarted extends DrawerEvent {}

/// Actualizar badges (sin recargar todo)
class DrawerBadgesUpdated extends DrawerEvent {
  final int unreadChats;
  final int pendingRecordatorios;
  final int newLeads;

  DrawerBadgesUpdated({
    this.unreadChats = 0,
    this.pendingRecordatorios = 0,
    this.newLeads = 0,
  });
}
