// lib/features/home/presentation/bloc/drawer/drawer_state.dart

abstract class DrawerState {
  const DrawerState();
}

class DrawerInitial extends DrawerState {
  const DrawerInitial();
}

class DrawerLoading extends DrawerState {
  const DrawerLoading();
}

class DrawerLoaded extends DrawerState {
  final String userName;
  final String userApe;       // ← descomentar
  final String? userSubtitle;
  final String? correoUser;   // ← descomentar
  final String? userAvatarUrl;
  final int unreadChats;
  final int pendingRecordatorios;
  final int newLeads;

  const DrawerLoaded({
    required this.userName,
    required this.userApe,     // ← descomentar
    this.userSubtitle,
    this.correoUser,           // ← descomentar
    this.userAvatarUrl,
    this.unreadChats = 0,
    this.pendingRecordatorios = 0,
    this.newLeads = 0,
  });

  bool get hasBadges =>
      unreadChats > 0 || pendingRecordatorios > 0 || newLeads > 0;
}

class DrawerError extends DrawerState {
  final String message;
  const DrawerError(this.message);
}
