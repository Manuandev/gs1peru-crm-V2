// lib\features\reminder\domain\repositories\reminder_repository.dart

import 'package:app_crm/features/reminder/index_reminder.dart';

abstract class ReminderRepository {
  Future<List<ReminderModel>> getReminders();
}
