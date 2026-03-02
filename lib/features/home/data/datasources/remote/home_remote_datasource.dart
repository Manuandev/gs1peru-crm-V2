// lib/features/home/data/datasources/remote/home_remote_datasource.dart
// ============================================================
// Llama a la API y retorna UserModel con todos los datos.
// ============================================================

import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/network/api_client.dart';
import 'package:app_crm/core/services/session_service.dart';
import 'package:app_crm/features/home/data/models/lead_model.dart';

class HomeRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<LeadItem>> listarLeads() async {
    final String body = '${_session.codUser}¯L';

    final String raw = await _api.postJsonGetText(ApiConstants.urlLeadsLst, body);

    if (raw.isEmpty) {
      throw HomeException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return LeadItem.parseLeadItemList(raw);
    } on FormatException catch (e) {
      throw HomeException(e.message);
    }
  }
}

class HomeException implements Exception {
  final String message;
  const HomeException(this.message);

  @override
  String toString() => message;
}
