// lib\features\chat\domain\usecases\get_chats_usecase.dart

import 'package:app_crm/features/reminder/index_reminder.dart';

class GetRemindersUseCase {
  final ReminderRepository repository;
  const GetRemindersUseCase(this.repository);

  Future<List<Reminder>> call() => repository.getReminders();
}
