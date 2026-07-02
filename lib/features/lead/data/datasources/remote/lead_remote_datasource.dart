// lib/features/lead/data/datasources/remote/lead_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

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

  Future<CrudResult> updateLeadCompleto(
    Lead lead, {
    String empresaEditar = '',
    String correoEditar = '',
    String nuevasEmpresas = '',
    String nuevosCorreos = '',
    String nuevosPrefijos = '',
    String nuevosNumeros = '',
  }) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final String body = [
      // field1 ID_NUMERO — el SP resuelve el contacto por CRM.T_CONTACTO_NUMERO.
      // lead.idLead en 0 le indica al SP que debe crear el lead (no actualizarlo).
      lead.idNumero, // field1  ID_NUMERO
      lead.idLead, // field2  ID_LEAD
      lead.idEstado, // field3  ID_ESTADO
      ParseUtils.orEmpty(lead.idCampania), // field4  ID_CAMPANIA
      ParseUtils.orEmpty(lead.idEvento), // field5  ID_OPORTUNIDAD
      ParseUtils.orEmpty(lead.idCanal), // field6  ID_CANAL
      ParseUtils.orEmpty(lead.idInteres), // field7  ID_INTERES
      lead.nombre, // field8  NOMBRES
      lead.apellidoPaterno, // field9  APELLIDO_P
      lead.apellidoMaterno, // field10 APELLIDO_M
      ParseUtils.orEmpty(lead.precioBase), // field11 PRECIO_BASE
      ParseUtils.orEmpty(lead.precio), // field12 PRECIO (costoFinal calculado)
      // lead.cantidad es int: el SP castea field13 con TRY_CAST(... AS INT) —
      // un string con decimales como "5.0" hace que TRY_CAST devuelva NULL y
      // nunca se guarda IN_PARTICIPANTES.
      ParseUtils.orEmpty(lead.cantidad), // field13 CANTIDAD
      ParseUtils.orEmpty(lead.descuento), // field14 DESCUENTO
      lead.nombreLead ?? '', // field15 NOMBRE_LD
      lead.modalidad ?? '', // field16 MODALIDAD
      _session.codUser, // field17 ID_USUARIO
      ip, // field18 IP_USUARIO
      coords, // field19 LL_USUARIO
      // TODO: [CRM].[CSV_LEADS_CUD_APP] task 'U' todavía no lee más allá de
      // field19 — cuando empresa/correo/teléfono/nuevos ítems sean editables
      // en el SP, hay que sumar aquí (en este orden, tras confirmar los
      // índices con el SP actualizado):
      // nuevasEmpresas, nuevosCorreos, nuevosPrefijos, nuevosNumeros,
      // empresaEditar, correoEditar
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

  Future<List<NegociacionModel>> getLeadNegociaciones(int idLead) async {
    final String body = '$idLead${sep}LN';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => NegociacionModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<HistorialComentarioModel>> getHistorialComentarios(
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
