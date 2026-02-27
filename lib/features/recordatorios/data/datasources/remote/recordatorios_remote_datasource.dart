// lib/features/recordatorios/data/datasources/remote/recordatorios_remote_datasource.dart

import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/network/api_client.dart';
import 'package:app_crm/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:app_crm/features/recordatorios/data/models/recordatorio_model.dart';

class RecordatoriosRemoteDatasource {
  final ApiClient _api = ApiClient();
  final IAuthRepository _authRepository;

  RecordatoriosRemoteDatasource({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  Future<List<RecordatorioItem>> listarRecordatorios() async {
    // ✅ Tomas el codUser del usuario en sesión
    final codUser = _authRepository.currentUser?.codUser ?? '';

    if (codUser.isEmpty) {
      throw RecordatoriosException('No hay sesión activa.');
    }

    final String body = '$codUser¯L';

    final String raw = await _api.postJsonGetText(
      ApiConstants.urlRecordatorios,
      body,
    );

    if (raw.isEmpty) {
      throw RecordatoriosException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return RecordatorioItem.parseLeadList(raw);
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
