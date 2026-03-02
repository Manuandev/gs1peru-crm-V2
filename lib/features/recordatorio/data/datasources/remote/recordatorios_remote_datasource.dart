// lib/features/recordatorios/data/datasources/remote/recordatorios_remote_datasource.dart

import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/network/api_client.dart';
import 'package:app_crm/core/services/session_service.dart';
import 'package:app_crm/features/recordatorio/data/models/recordatorio_model.dart';

class RecordatoriosRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<RecordatorioItem>> listarRecordatorios() async {
    final String body = '${_session.codUser}¯L';

    final String raw = await _api.postJsonGetText(
      ApiConstants.urlRecordatoriosLst,
      body,
    );

    if (raw.isEmpty) {
      throw RecordatoriosException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return RecordatorioItem.parseRecordatorioList(raw);
    } on FormatException catch (e) {
      throw RecordatoriosException(e.message);
    }
  }
}

class RecordatoriosException implements Exception {
  final String message;
  const RecordatoriosException(this.message);

  @override
  String toString() => message;
}
