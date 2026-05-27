// lib\features\lead\data\datasources\remote\lead_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<LeadModel>> getLeads() async {
    final String body = '${_session.codUser}¯L';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => LeadModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
