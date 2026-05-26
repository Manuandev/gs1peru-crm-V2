// lib\features\home\data\datasources\remote\home_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/core/network/api_result.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<HomeModel> getData() async {
    final String body = '${_session.codUser}¯L';

    final result = await _api.postSafe(ApiConstants.urlHomeLst, body);

    return switch (result) {
      ApiSuccess(:final data) => HomeModel.parse(data),
      ApiEmpty() => const HomeModel(
          totConversaciones: 0,
          totProspectos: 0,
          totPropuestas: 0,
          totCobranza: 0,
          prioridades: [],
        ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
