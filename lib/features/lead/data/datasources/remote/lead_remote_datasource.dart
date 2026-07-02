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
      _orEmpty(lead.idCampania), // field4  ID_CAMPANIA
      _orEmpty(lead.idEvento), // field5  ID_OPORTUNIDAD
      _orEmpty(lead.idCanal), // field6  ID_CANAL
      _orEmpty(lead.idInteres), // field7  ID_INTERES
      lead.nombre, // field8  NOMBRES
      lead.apellidoPaterno, // field9  APELLIDO_P
      lead.apellidoMaterno, // field10 APELLIDO_M
      nuevosCorreos, // field11 nuevos correos ± separados
      nuevosPrefijos, // field12 nuevos prefijos ± separados
      nuevosNumeros, // field13 nuevos números ± separados (mismo índice que field12)
      // TODO(mejora): unificar field12+field13 en un solo string +51¶999000001±+1¶987654321
      // usando AppConstants.sepComodin3 (¶) entre prefijo/número y sepComodin2 (±) entre entradas.
      // Actualizar getter nuevosTelefonosStr en EditLeadContactoSection y SP para usar
      // fnSplitStringTable05(@TELEFONOS_STR, @sepComodin2, @sepComodin3).
      _orEmpty(lead.precioBase), // field14 PRECIO_BASE
      _orEmpty(lead.precio), // field15 PRECIO (costoFinal calculado)
      // lead.cantidad es int: el SP castea field16 con TRY_CAST(... AS INT) —
      // un string con decimales como "5.0" hace que TRY_CAST devuelva NULL y
      // nunca se guarda IN_PARTICIPANTES.
      _orEmpty(lead.cantidad), // field16 CANTIDAD
      _orEmpty(lead.descuento), // field17 DESCUENTO
      _session.codUser, // field18 ID_USUARIO
      ip, // field19 IP_USUARIO
      coords, // field20 LL_USUARIO
      lead.nombreLead ?? '', // field21 NOMBRE_LD
      lead.modalidad ?? '', // field22 MODALIDAD
      // TODO: [CRM].[CSV_LEADS_CUD_APP] task 'U' (Fnsplitstringtable25, tope 25
      // fields) todavía no lee más allá de field22 — cuando empresa/correo/
      // teléfono sean editables, hay que ampliar el split y sumar estos 4:
      // nuevasEmpresas,                 // field23 nuevas empresas ± separadas
      // '',                             // field24 CARGO placeholder
      // empresaEditar,                  // field25 editar empresa actual ('' si no cambió)
      // correoEditar,                   // field26 editar correo actual ('' si no cambió) — excede el tope de 25, requeriría otra función split
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
