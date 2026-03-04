// lib\features\lead\data\datasources\remote\lead_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<LeadModel>> getLeads() async {
    final String body = '${_session.codUser}¯L';

    final String raw = await _api.postJsonGetText(
      ApiConstants.urlLeadsLst,
      body,
    );

    if (raw.isEmpty) {
      throw AppException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return LeadModel.parseList(raw);
    } on FormatException catch (e) {
      throw AppException(e.message);
    }
  }
}
