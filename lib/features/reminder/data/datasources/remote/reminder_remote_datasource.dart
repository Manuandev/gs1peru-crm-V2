// lib\features\reminder\data\datasources\remote\reminder_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/reminder/index_reminder.dart';

class ReminderRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<ReminderModel>> getReminders() async {
    final String body = '${_session.codUser}¯L';

    final String raw = await _api.postJsonGetText(
      ApiConstants.urlRecordatoriosLst,
      body,
    );

    if (raw.isEmpty) {
      throw AppException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return ReminderModel.parseList(raw);
    } on FormatException catch (e) {
      throw AppException(e.message);
    }
  }
}
