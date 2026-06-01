// lib\features\home\presentation\bloc\notifications\notifications_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final GetNotificationsUseCase _getData;

  NotificationsBloc({required GetNotificationsUseCase getData})
    : _getData = getData,
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
      final notification = await _getData.call();

      emit(
        NotificationsLoaded(
          notification: notification,
        ),
      );
    } on AppException catch (e) {
      emit(NotificationsError(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(NotificationsError(e.toString()));
    }
  }
}
