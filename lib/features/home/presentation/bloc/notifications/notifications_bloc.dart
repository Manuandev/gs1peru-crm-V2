// lib\features\home\presentation\bloc\notifications\notifications_bloc.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class NotificationsBloc extends Bloc<HomeEvent, HomeState> {
  final GetNotificationUseCase _getData;
  final _session = SessionService();

  NotificationsBloc({required GetNotificationUseCase getData})
    : _getData = getData,
      super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefresh>(_onRefresh);
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(HomeRefresh event, Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
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
