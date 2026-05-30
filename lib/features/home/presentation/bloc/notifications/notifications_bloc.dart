// lib\features\home\presentation\bloc\notifications\notifications_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/home/index_home.dart';

class NotificationsBloc extends Bloc<NotificationEvent, NotificationsState> {
  final GetNotificationUseCase _getData;

  NotificationsBloc({required GetNotificationUseCase getData})
    : _getData = getData,
      super(const NotificationsInitial()) {
    on<NotificationStarted>(_onStarted);
    on<NotificationRefresh>(_onRefresh);
  }

  Future<void> _onStarted(NotificationStarted event, Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(NotificationRefresh event, Emitter<NotificationsState> emit) async {
    emit(const NotificationsLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<NotificationsState> emit) async {
    // try {
    //   final home = await _getData.call();

    //   emit(HomeLoaded(home: home, usuario: _session.user!));
    // } on AppException catch (e) {
    //   emit(HomeError(e.message));
    // } catch (e, stackTrace) {
    //   addError(e, stackTrace);
    //   emit(HomeError(e.toString()));
    // }
  }
}
