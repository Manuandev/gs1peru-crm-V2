// lib/features/home/presentation/bloc/drawer/drawer_bloc.dart

import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'drawer_event.dart';
import 'drawer_state.dart';

class DrawerBloc extends Bloc<DrawerEvent, DrawerState> {
  final IAuthRepository _authRepository;

  DrawerBloc({required IAuthRepository authRepository})
    : _authRepository = authRepository,
      super(const DrawerInitial()) {
    on<DrawerStarted>(_onDrawerStarted);
    on<DrawerBadgesUpdated>(_onDrawerBadgesUpdated);
  }

  Future<void> _onDrawerStarted(
    DrawerStarted event,
    Emitter<DrawerState> emit,
  ) async {
    emit(const DrawerLoading());

    // currentUser siempre está en memoria si llegaste hasta aquí.
    // Si es null algo muy raro pasó (no debería ocurrir post-login).
    final user = _authRepository.currentUser;

    if (user == null) {
      emit(const DrawerError('Sin sesión activa'));
      return;
    }

    emit(
      DrawerLoaded(
        userName: user.codUser,
        userApe: user.userApe,
        userSubtitle: user.correoUser,
        correoUser: user.correoUser,
        unreadChats: 0,
        pendingRecordatorios: 0,
        newLeads: 0,
      ),
    );
  }

  Future<void> _onDrawerBadgesUpdated(
    DrawerBadgesUpdated event,
    Emitter<DrawerState> emit,
  ) async {
    final current = state;
    if (current is! DrawerLoaded) return;

    emit(
      DrawerLoaded(
        userName: current.userName,
        userApe: current.userApe,
        userSubtitle: current.userSubtitle,
        correoUser: current.correoUser,
        userAvatarUrl: current.userAvatarUrl,
        unreadChats: event.unreadChats,
        pendingRecordatorios: event.pendingRecordatorios,
        newLeads: event.newLeads,
      ),
    );
  }
}
