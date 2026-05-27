// lib\features\reminder\data\datasources\remote\reminder_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';

class ReminderRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<ReminderModel>> getReminders() async {
    final String body = '${_session.codUser}¯L';

    final result = await _api.postSafe(ApiConstants.urlRecordatoriosLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ReminderModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
