// lib/core/network/catalog_remote_datasource.dart

// catalog_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';

class CatalogsRemoteDatasource {
  final ApiClient _api = ApiClient();

  Future<ListasGenericasModel> getListas() async {
    final String body = 'L';

    final result = await _api.postSafe(ApiConstants.urlListasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ListasGenericasModel.parse(data),
      ApiEmpty() => ListasGenericasModel(
        campanias: [],
        oportunidades: [],
        canales: [],
        intereses: [],
      ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
