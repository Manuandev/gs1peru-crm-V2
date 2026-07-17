// lib/features/home/presentation/bloc/notifications/notifications_bloc.dart

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getData;
  final MarkNotificationsReadUseCase _markRead;

  NotificationsBloc({
    required GetNotificationsUseCase getData,
    required MarkNotificationsReadUseCase markRead,
  }) : _getData = getData,
       _markRead = markRead,
       super(const NotificationsInitial()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsRefresh>(_onRefresh);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    await _loadData(emit);
    // Al entrar a la pantalla se marcan todas como leídas — el estado ya
    // emitido conserva el "leido" previo, así el puntito azul se ve en esta
    // visita y desaparece recién en la siguiente.
    unawaited(_marcarLeidas());
  }

  Future<void> _marcarLeidas() async {
    try {
      await _markRead.call();
    } catch (e, stackTrace) {
      addError(e, stackTrace);
    }
  }

  Future<void> _onRefresh(
    NotificationsRefresh event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<NotificationsState> emit) async {
    try {
      final notificationes = await _getData.call();
      emit(NotificationsLoaded(notificationes: notificationes));
    } on AppException catch (e) {
      emit(NotificationsError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(NotificationsError(e.toString()));
    }
  }
}
