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
    // Sin async, sin Loading — los datos están en memoria, es instantáneo
    final user = _session.user!;

    // Preservar badges si ya había un estado cargado
    final previous = state is DrawerLoaded ? state as DrawerLoaded : null;

    emit(
      DrawerLoaded(
        userName: user.codUser,
        userApe: user.userApe,
        userSubtitle: user.correoUser,
        conversaciones: previous?.conversaciones ?? 0,
        prospectos: previous?.prospectos ?? 0,
        propuestas: previous?.propuestas ?? 0,
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

    // copyWithBadges — no repetimos todos los campos
    emit(
      current.copyWithBadges(
        conversaciones: event.conversaciones,
        // pendingReminders: event.prospectos,
        // newLeads: event.propuestas,
        prospectos: event.prospectos,
        propuestas: event.propuestas,
        cobranzas: event.cobranza,
      ),
    );
  }
}
