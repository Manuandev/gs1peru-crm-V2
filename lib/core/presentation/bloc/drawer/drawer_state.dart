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
  final bool isModerador;
  final int conversaciones;
  final int prospectos;
  final int cobranzas;

  const DrawerLoaded({
    required this.userName,
    required this.userApe,
    required this.isModerador,
    this.userSubtitle,
    this.conversaciones = 0,
    this.prospectos = 0,
    this.cobranzas = 0,
  });

  bool get hasBadges => conversaciones > 0 || prospectos > 0 || cobranzas > 0;

  DrawerLoaded copyWithBadges({
    int? conversaciones,
    int? prospectos,
    int? cobranzas,
  }) {
    return DrawerLoaded(
      userName: userName,
      userApe: userApe,
      userSubtitle: userSubtitle,
      isModerador: isModerador,
      conversaciones: conversaciones ?? this.conversaciones,
      prospectos: prospectos ?? this.prospectos,
      cobranzas: cobranzas ?? this.cobranzas,
    );
  }
}
