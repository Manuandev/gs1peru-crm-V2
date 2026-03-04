// lib\core\presentation\bloc\drawer\drawer_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_crm/core/index_core.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final _session = SessionService();

  DrawerBloc() : super(const DrawerIdle()) {
    on<DrawerStarted>(_onDrawerStarted);
    on<DrawerBadgesUpdated>(_onDrawerBadgesUpdated);
  }

  void _onDrawerStarted(DrawerStarted event, Emitter<DrawerState> emit) {
    // Sin async, sin Loading — los datos están en memoria, es instantáneo
    final user = _session.user!;

    // Preservar badges si ya había un estado cargado
    final previous = state is DrawerLoaded ? state as DrawerLoaded : null;

    emit(
      DrawerLoaded(
        userName: user.codUser,
        userApe: user.userApe,
        userSubtitle: user.correoUser,
        unreadChats: previous?.unreadChats ?? 0,
        pendingReminders: previous?.pendingReminders ?? 0,
        newLeads: previous?.newLeads ?? 0,
      ),
    );
  }

  void _onDrawerBadgesUpdated(
    DrawerBadgesUpdated event,
    Emitter<DrawerState> emit,
  ) {
    final current = state;
    if (current is! DrawerLoaded) return;

    // copyWithBadges — no repetimos todos los campos
    emit(
      current.copyWithBadges(
        unreadChats: event.unreadChats,
        pendingReminders: event.pendingReminders,
        newLeads: event.newLeads,
      ),
    );
  }
}
