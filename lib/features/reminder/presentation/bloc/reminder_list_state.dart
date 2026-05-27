// lib\features\reminder\presentation\bloc\reminder_list_state.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/reminder/index_reminder.dart';

abstract class ReminderListState extends Equatable {
  const ReminderListState();

  @override
  List<Object?> get props => [];
}

class ReminderListInitial extends ReminderListState {
  const ReminderListInitial();
}

class ReminderListLoading extends ReminderListState {
  const ReminderListLoading();
}

class ReminderListLoaded extends ReminderListState {
  final List<Reminder> reminders; // Recordatorios

  const ReminderListLoaded({required this.reminders});
}

class ReminderListError extends ReminderListState {
  final String message;
  const ReminderListError(this.message);

  @override
  List<Object?> get props => [message];
}
