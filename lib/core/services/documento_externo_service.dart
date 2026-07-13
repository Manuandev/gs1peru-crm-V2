// lib/core/services/documento_externo_service.dart

import 'package:app_crm/core/index_core.dart';

// Autocompletado por DNI/RUC — Clientes/BuscarDocumento. El body es solo el
// número de documento; el token lo antepone TokenBodyInterceptor.
class DocumentoExternoService {
  final ApiClient _api = ApiClient();

  Future<DocumentoExterno?> buscar(String nroDocumento) async {
    final result = await _api.postSafe(
      ApiConstants.urlBuscarDocumento,
      nroDocumento,
    );

    return switch (result) {
      ApiSuccess(:final data) => DocumentoExternoModel.fromRawString(data),
      ApiEmpty() => null,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
