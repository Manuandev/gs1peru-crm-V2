// lib\features\reminder\presentation\bloc\reminder_list_bloc.dart

import 'package:app_crm/features/reminder/index_reminder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReminderListBloc extends Bloc<ReminderListEvent, ReminderListState> {
  final GetRemindersUseCase _getReminders;

  ReminderListBloc(this._getReminders) : super(const ReminderListInitial()) {
    on<ReminderListStarted>(_onStarted);
    on<ReminderListRefresh>(_onRefresh);
  }

  Future<void> _onStarted(
    ReminderListStarted event,
    Emitter<ReminderListState> emit,
  ) async {
    emit(const ReminderListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    ReminderListRefresh event,
    Emitter<ReminderListState> emit,
  ) async {
    emit(const ReminderListLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ReminderListState> emit) async {
    try {
      final remindersF = _getReminders();

      final reminders = await remindersF.catchError((_) => <ReminderModel>[]);

      emit(ReminderListLoaded(reminders: reminders));
    } catch (e, stackTrace) {
      addError(e, stackTrace);

      emit(ReminderListError(e.toString()));
    }
  }
}
