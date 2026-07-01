// lib/core/presentation/bloc/drawer/drawer_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final _session = SessionService();

  DrawerBloc() : super(const DrawerIdle()) {
    on<DrawerStarted>(_onDrawerStarted);
    on<DrawerBadgesUpdated>(_onDrawerBadgesUpdated);
  }

  void _onDrawerStarted(DrawerStarted event, Emitter<DrawerState> emit) {
    final user = _session.user!;
    final previous = state is DrawerLoaded ? state as DrawerLoaded : null;

    emit(
      DrawerLoaded(
        userName: user.codUser,
        userApe: user.userApe,
        userSubtitle: user.correoUser,
        isModerador: user.isModerador,
        conversaciones: previous?.conversaciones ?? 0,
        seguimientos: previous?.seguimientos ?? 0,
        cobranzas: previous?.cobranzas ?? 0,
      ),
    );
  }

  void _onDrawerBadgesUpdated(
    DrawerBadgesUpdated event,
    Emitter<DrawerState> emit,
  ) {
    final current = state;
    if (current is! DrawerLoaded) return;

    emit(
      current.copyWithBadges(
        conversaciones: event.conversaciones,
        seguimientos: event.seguimientos,
        cobranzas: event.cobranza,
      ),
    );
  }
}
