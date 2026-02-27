import 'package:app_crm/core/presentation/bloc/drawer/drawer_event.dart';
import 'package:app_crm/core/presentation/bloc/drawer/drawer_state.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final IAuthRepository _authRepository;

  DrawerBloc({required IAuthRepository authRepository})
      : _authRepository = authRepository,
        super(const DrawerIdle()) {
    on<DrawerStarted>(_onDrawerStarted);
    on<DrawerBadgesUpdated>(_onDrawerBadgesUpdated);
  }

  void _onDrawerStarted(DrawerStarted event, Emitter<DrawerState> emit) {
    // Sin async, sin Loading — los datos están en memoria, es instantáneo
    final user = _authRepository.currentUser;
    if (user == null) return; // No debería pasar nunca post-login

    emit(DrawerLoaded(
      userName: user.codUser,
      userApe: user.userApe,
      userSubtitle: user.correoUser,
    ));
  }

  void _onDrawerBadgesUpdated(
    DrawerBadgesUpdated event,
    Emitter<DrawerState> emit,
  ) {
    final current = state;
    if (current is! DrawerLoaded) return;

    // copyWithBadges — no repetimos todos los campos
    emit(current.copyWithBadges(
      unreadChats: event.unreadChats,
      pendingRecordatorios: event.pendingRecordatorios,
      newLeads: event.newLeads,
    ));
  }
}