// lib/core/presentation/bloc/drawer/drawer_state.dart
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
  final int conversaciones;
  final int prospectos;
  final int propuestas;
  final int cobranzas;

  const DrawerLoaded({
    required this.userName,
    required this.userApe,
    this.userSubtitle,
    this.userAvatarUrl,
    this.conversaciones = 0,
    this.prospectos = 0,
    this.propuestas = 0,
    this.cobranzas = 0,
  });

  bool get hasBadges =>
      conversaciones > 0 || prospectos > 0 || propuestas > 0 || cobranzas > 0;

  // Para actualizar solo los badges sin repetir todos los campos
  DrawerLoaded copyWithBadges({
    int? conversaciones,
    int? prospectos,
    int? propuestas,
    int? cobranzas,
  }) {
    return DrawerLoaded(
      userName: userName,
      userApe: userApe,
      userSubtitle: userSubtitle,
      userAvatarUrl: userAvatarUrl,
      conversaciones: conversaciones ?? this.conversaciones,
      prospectos: prospectos ?? this.prospectos,
      propuestas: propuestas ?? this.propuestas,
      cobranzas: cobranzas ?? this.cobranzas,
    );
  }
}
