abstract class DrawerState {
  const DrawerState();
}

// Estado antes de que el usuario haga login — drawer vacío
class DrawerIdle extends DrawerState {
  const DrawerIdle();
}

// Estado normal — drawer con datos listos
class DrawerLoaded extends DrawerState {
  final String userName;
  final String userApe;
  final String? userSubtitle;
  final String? userAvatarUrl;
  final int unreadChats;
  final int pendingRecordatorios;
  final int newLeads;

  const DrawerLoaded({
    required this.userName,
    required this.userApe,
    this.userSubtitle,
    this.userAvatarUrl,
    this.unreadChats = 0,
    this.pendingRecordatorios = 0,
    this.newLeads = 0,
  });

  bool get hasBadges =>
      unreadChats > 0 || pendingRecordatorios > 0 || newLeads > 0;

  // Para actualizar solo los badges sin repetir todos los campos
  DrawerLoaded copyWithBadges({
    required int unreadChats,
    required int pendingRecordatorios,
    required int newLeads,
  }) {
    return DrawerLoaded(
      userName: userName,
      userApe: userApe,
      userSubtitle: userSubtitle,
      userAvatarUrl: userAvatarUrl,
      unreadChats: unreadChats,
      pendingRecordatorios: pendingRecordatorios,
      newLeads: newLeads,
    );
  }
}