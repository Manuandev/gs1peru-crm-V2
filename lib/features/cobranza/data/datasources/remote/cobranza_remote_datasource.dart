// lib/features/cobranza/data/datasources/remote/cobranza_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<CobranzaModel>> getCobranzas() async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';

    final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => CobranzaModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'DT' — mismo endpoint urlCobranzasLst, body numSol¯DT (mismo patrón
  // que SolicitudRemoteDatasource.getSolicitudDetalle()).
  Future<CobranzaDetalle?> getDetalleCobranza(String numSol) async {
    final body = '$numSol${AppConstants.sepListas}DT';

    final result = await _api.postSafe(ApiConstants.urlCobranzasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => CobranzaDetalleModel.parse(data),
      ApiEmpty() => null,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<CrudResult> facturarContado(String idCobranza) async {
    // Todo: conectar con endpoint real
    // final body = '${[_session.codUser, idCobranza, 'FC'].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';
    // final raw = await _api.postJsonGetText(ApiConstants.urlCobranzasLst, body);
    // return parseCrudResponse(raw);
    await Future.delayed(const Duration(milliseconds: 500));
    return const CrudOk('Factura generada correctamente');
  }

  Future<CrudResult> guardarPlanCredito(
    String idCobranza,
    List<CuotaPlan> cuotas,
  ) async {
    // Todo: conectar con endpoint real
    // Serializar: idCobranza + cuotas separadas por AppConstants.sepRegistros
    // final body = ...
    // return parseCrudResponse(raw);
    await Future.delayed(const Duration(milliseconds: 500));
    return const CrudOk('Plan de crédito guardado correctamente');
  }
}
