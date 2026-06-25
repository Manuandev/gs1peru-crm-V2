// lib/features/lead/data/datasources/remote/lead_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  String _orEmpty(dynamic val) =>
      (val == null || val == 0) ? '' : val.toString();

  Future<List<LeadModel>> getLeads() async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(camp)}${sep}LS';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => LeadModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<void> marcarFavorito(int idLead, bool isFavorito) async {
    // TODO: conectar a ApiConstants.urlLeadsCud cuando se defina el SP/proceso
    await Future.delayed(const Duration(milliseconds: 300));
  }

  Future<CrudResult> updateLeadCompleto(Lead lead) async {
    if (lead.idLead == 0) {
      return const CrudError('ID de lead inválido. No se puede actualizar.');
    }

    final ip     = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final String body = [
      lead.idContacto,                   // field1  ID_CONTACTO
      lead.idLead,                       // field2  ID_LEAD
      lead.idEstado,                     // field3  ID_ESTADO
      _orEmpty(lead.idCampania),         // field4  ID_CAMPANIA
      _orEmpty(lead.idEvento),           // field5  ID_OPORTUNIDAD
      _orEmpty(lead.idCanal),            // field6  ID_CANAL
      _orEmpty(lead.idInteres),          // field7  ID_INTERES
      lead.nombre,                       // field8  NOMBRES
      lead.apellidoPaterno,              // field9  APELLIDO_P
      lead.apellidoMaterno,              // field10 APELLIDO_M
      lead.correo,                       // field11 CORREO
      lead.prefijo,                      // field12 PREFIJO_NM
      lead.numero,                       // field13 NUMERO
      _orEmpty(lead.precioBase),         // field14 PRECIO_BASE
      _orEmpty(lead.precio),             // field15 PRECIO (costoFinal calculado)
      _orEmpty(lead.cantidad),           // field16 CANTIDAD
      _orEmpty(lead.descuento),          // field17 DESCUENTO
      _session.codUser,                  // field18 ID_USUARIO
      ip,                                // field19 IP_USUARIO
      coords,                            // field20 LL_USUARIO
    ].join(camp);

    final result = await _api.postSafe(ApiConstants.urlLeadsCud, '$body${sep}U');

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  Future<LeadDetalleModel> getLeadDetalle(int idLead) async {
    final String body = '$idLead${sep}DT';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => LeadDetalleModel.parse(data),
      ApiEmpty() => throw const AppException('No se encontró el lead.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<NegociacionLeadModel>> getLeadNegociaciones(int idLead) async {
    final String body = '$idLead${sep}LN';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);


    return switch (result) {
      ApiSuccess(:final data) => NegociacionLeadModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
