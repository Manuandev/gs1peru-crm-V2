// lib/features/lead/data/datasources/remote/lead_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  Future<List<ContactoNegociacionModel>> getLeads() async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(camp)}${sep}LS';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ContactoNegociacionModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<CrudResult> updateNegociacion(
    Negociacion negociacion,
    int idNumero,
  ) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final String body = [
      idNumero,
      negociacion.idLead,
      negociacion.idEstado,
      ParseUtils.orEmpty(negociacion.idCampania),
      ParseUtils.orEmpty(negociacion.idOportunidad),
      ParseUtils.orEmpty(negociacion.idCanal),
      ParseUtils.orEmpty(negociacion.idInteres),
      ParseUtils.orEmpty(negociacion.precioBase),
      ParseUtils.orEmpty(negociacion.precio),
      ParseUtils.orEmpty(negociacion.cantidad),
      ParseUtils.orEmpty(negociacion.descuento),
      negociacion.idMoneda,
      negociacion.nombre,
      negociacion.modalidad,
      _session.codUser,
      ip,
      coords,
    ].join(camp);

    final result = await _api.postSafe(
      ApiConstants.urlLeadsCud,
      '$body${sep}U',
    );

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  Future<NegociacionModel> getLeadDetalle(int idLead) async {
    final String body = '$idLead${sep}DT';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) =>
        NegociacionModel.parseDetalle(data) ??
            (throw const AppException('No se encontró el lead.')),
      ApiEmpty() => throw const AppException('No se encontró el lead.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'DN' — mismo shape de columnas que 'DT', pero ancla en NÚMERO (el
  // lead más reciente de ese número). Usada por Seguimiento ("Ver detalle"),
  // que ahora navega por idNumero, no por idLead — 'DT' se queda reservado
  // para Conversaciones y para ver un lead histórico puntual.
  Future<NegociacionModel> getLeadDetallePorNumero(int idNumero) async {
    final String body = '$idNumero${sep}DN';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) =>
        NegociacionModel.parseDetalle(data) ??
            (throw const AppException('No se encontró el lead.')),
      ApiEmpty() => throw const AppException('No se encontró el lead.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<NegociacionModel>> obtenerNegociaciones(int idNumero) async {
    final String body = '$idNumero${sep}LN';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => NegociacionModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<HistorialComentarioModel>> obtenerHistorialComentarios(
    int idNumero,
  ) async {
    final String body = '$idNumero${sep}LCG';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => HistorialComentarioModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
