// lib/core/network/catalog_remote_datasource.dart

// catalog_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';

class CatalogsRemoteDatasource {
  final ApiClient _api = ApiClient();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  Future<ListasGenericasModel> getListas() async {
    final String body = '${sep}L';

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

  // Task 'TC' — SOLO tipo de cambio del día (venta/compra), sin traer el
  // catálogo completo. Usado al validar el plan de crédito en cobranza/
  // (mismo endpoint urlListasLst, cuerpo distinto) — ver cobranza/CLAUDE.md.
  Future<TipoCambioItem> getTipoCambio() async {
    final String body = '${sep}TC';

    final result = await _api.postSafe(ApiConstants.urlListasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => data.trim().isEmpty
          ? const TipoCambioItem()
          : TipoCambioItemModel.fromRawString(data),
      ApiEmpty() => const TipoCambioItem(),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
