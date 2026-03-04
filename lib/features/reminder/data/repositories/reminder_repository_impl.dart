// lib\features\reminder\data\repositories\reminder_repository_impl.dart

import 'package:app_crm/features/reminder/index_reminder.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderRemoteDatasource _remote;

  ReminderRepositoryImpl(this._remote);

  @override
  Future<List<ReminderModel>> getReminders() => _remote.getReminders();
}
