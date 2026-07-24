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

  // Task 'LHN' — historial de seguimiento de todos los leads activos del
  // mismo número. Usado por el tab Historial en Seguimiento
  // (ContactoDetalleView) y en Conversaciones (ChatLeadPanel) — mismo
  // llamado en los dos.
  Future<List<HistorialComentarioModel>> obtenerHistorialSeguimientoPorNumero(
    int idNumero,
  ) async {
    final String body = '$idNumero${sep}LHN';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) =>
        HistorialComentarioModel.parseListSeguimiento(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'D' de CRM.CSV_CONTACTO_LST_APP — formato confirmado contra el .sql
  // real (2026-07-23). ⚠️ Sigue pendiente confirmar la ruta del controller
  // C# real en ApiConstants.lstContacto (placeholder). Si el número todavía
  // no tiene contacto, el SP devuelve '' → ApiEmpty → ContactoDetalle en
  // blanco (modo "crear").
  Future<ContactoDetalleModel> getContactoPorIdNumero(int idNumero) async {
    final String body = '$idNumero${sep}D';

    final result = await _api.postSafe(ApiConstants.urlContactoLst, body);

    return switch (result) {
      ApiSuccess(:final data) =>
        ContactoDetalleModel.fromRawString(data, idNumero),
      ApiEmpty() => ContactoDetalleModel.vacio(idNumero),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'U' de CRM.CSV_CONTACTO_CUD_APP — rama CREATE y UPDATE implementadas
  // (2026-07-23). Envelope de 6 secciones separadas por sepListas (¯):
  // token(auto) ¯ datosContacto ¯ 'U' ¯ datosNumeros ¯ datosCorreos ¯ datosEmpresas
  // — el task va justo después de datosContacto, no al final (a diferencia
  // del resto de SPs de este proyecto).
  // Números/correos/empresas: cada fila manda su propio id primero (0 =
  // nueva, el SP la crea; con id = ya existe y el SP la ignora tal cual, no
  // la actualiza — pedido de negocio: "si algo ya se tiene, que se quede
  // ahí nomás"). El UPDATE de T_CONTACTO sí sobreescribe todos sus campos
  // directo. Validación de número/correo de OTRO contacto sigue activa
  // (solo sobre filas nuevas); la de documento duplicado quedó deshabilitada
  // a pedido de negocio. Ver lead/CLAUDE.md.
  Future<CrudResult> guardarContacto(ContactoDetalle contacto) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    // UBIGEO real es VARCHAR(6) = dpto(2)+prov(2)+dis(2) concatenados — el
    // SP no recibe los 3 niveles por separado.
    final ubigeo = '${contacto.idDepartamento}${contacto.idProvincia}${contacto.idDistrito}';

    // Salta la validación de "DNI duplicado" cuando ya hay un idContacto
    // (edición, o segundo intento donde el usuario ya confirmó continuar)
    // — mismo criterio pendiente de reforzar del lado del SP, ver
    // lead/CLAUDE.md ("reglas de negocio de duplicados").
    final ibValidacion = contacto.idContacto == 0 ? 1 : 0;

    final datosContacto = [
      contacto.idNumero,
      contacto.idContacto,
      contacto.nombre,
      contacto.apellidoPaterno,
      contacto.apellidoMaterno,
      contacto.idTipoDocumento,
      contacto.numeroDocumento,
      contacto.idNacionalidad,
      contacto.idPais,
      contacto.direccion,
      ubigeo,
      contacto.prefijoContacto,
      contacto.linkedin,
      ibValidacion,
      _session.codUser,
      ip,
      coords,
    ].join(camp);

    // idNumero va primero: 0 (fila nueva, el SP la crea y la vincula) o el
    // id real (ya existe y ya está vinculada — el SP la ignora tal cual,
    // no se actualiza ni esPrincipal/esFavorito).
    final datosNumeros = contacto.numeros
        .map(
          (n) => [
            n.idNumero,
            n.prefijo,
            n.numero,
            n.esPrincipal ? 1 : 0,
            n.esFavorito ? 1 : 0,
          ].join(camp),
        )
        .join(AppConstants.sepRegistros);

    // idCorreo va primero — mismo criterio que idNumero/idEmpresaContacto.
    final datosCorreos = contacto.correos
        .map((c) => [c.idCorreo, c.correo].join(camp))
        .join(AppConstants.sepRegistros);

    // Empresas — idEmpresaContacto va primero: 0 (fila nueva, la agrega el
    // SP) o el id real (ya existe, el SP la ignora para no duplicarla al
    // reenviar la lista completa en cada guardado). Ubigeo de empresa
    // (idDepartamento+idProvincia+idDistrito, 2 dígitos c/u) se concatena
    // igual que el ubigeo del contacto — ver `ubigeo` más arriba. area/cargo
    // son ids de catálogo (INT) — ver lead/CLAUDE.md.
    final datosEmpresas = contacto.empresas
        .map(
          (e) => [
            e.idEmpresaContacto,
            e.idPais,
            e.ruc,
            e.nombreEmpresa,
            e.direccion,
            '${e.idDepartamento}${e.idProvincia}${e.idDistrito}',
            e.area,
            e.cargo,
          ].join(camp),
        )
        .join(AppConstants.sepRegistros);

    final String body = [
      datosContacto,
      'U',
      datosNumeros,
      datosCorreos,
      datosEmpresas,
    ].join(sep);

    final result = await _api.postSafe(ApiConstants.urlContactoCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }
}
