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

  // idContacto — 2026-08-03: antes se mandaba idNumero como field1, pero el
  // SP (CRM.CSV_LEADS_CUD_APP, task 'U') lo parsea como @ID_CONTACTO y lo
  // graba directo en T_LEAD.ID_CONTACTO (columna ya existente ahí) — bug
  // real: se guardaba el id del NÚMERO donde la tabla espera el id de
  // CONTACTO. Un lead siempre tiene un contacto (ya no siempre "el mismo
  // número"), así que este es el ancla correcta para crear/actualizar.
  Future<CrudResult> updateNegociacion(
    Negociacion negociacion,
    int idContacto,
  ) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final String body = [
      idContacto,
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

  // Task 'DN' — mismo shape de columnas que 'DT', pero ancla en CONTACTO (el
  // lead más reciente de ese contacto). Usada por Seguimiento ("Ver
  // detalle"), que ahora navega por idContacto, no por idLead — 'DT' se
  // queda reservado para Conversaciones y para ver un lead histórico puntual.
  // 2026-08-03 — migrado de idNumero a idContacto (SP y cliente): un lead
  // siempre tiene contacto (T_LEAD.ID_CONTACTO), el número puede
  // cambiar/duplicarse.
  Future<NegociacionModel> getLeadDetallePorContacto(int idContacto) async {
    final String body = '$idContacto${sep}DN';

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

  // Task 'LN' — historial de negociaciones del CONTACTO. 2026-08-03 —
  // migrado de idNumero a idContacto (mismo motivo que
  // getLeadDetallePorContacto arriba).
  Future<List<NegociacionModel>> obtenerNegociaciones(int idContacto) async {
    final String body = '$idContacto${sep}LN';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => NegociacionModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'LHN' — historial de seguimiento de todos los leads activos del
  // mismo CONTACTO. Usado por el tab Historial en Seguimiento
  // (ContactoDetalleView) y en Conversaciones (ChatLeadPanel) — mismo
  // llamado en los dos. 2026-08-03 — migrado de idNumero a idContacto (mismo
  // motivo que getLeadDetallePorContacto arriba).
  Future<List<HistorialComentarioModel>> obtenerHistorialSeguimientoPorContacto(
    int idContacto,
  ) async {
    final String body = '$idContacto${sep}LHN';

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

    // ⚠️ 2026-08-03 — contacto.idNumero (field1) es MUERTO del lado del SP
    // (CSV_CONTACTO_CUD_APP, tasks 'U'/'US') — se parsea pero nunca se usa;
    // el contacto ancla en idContacto (field2, 0 = crear). Se sigue mandando
    // por compatibilidad de formato con el SP, no porque el SP lo necesite.
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
    // son TEXTO LIBRE (NOM_AREA/NOM_CARGO, ya no ID_AREA/ID_CARGO) — el
    // combo solo sugiere, nunca fuerza un id de catálogo, ver lead/CLAUDE.md.
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

  // Task 'DS' de CRM.CSV_CONTACTO_LST_APP — detalle SIMPLE por idContacto,
  // pantalla EditContactoSimple (versión reducida de EditContacto, pedido
  // de negocio 2026-07-27, ver lead/CLAUDE.md). Migrado de idNumero a
  // idContacto como ancla (2026-08-03) — el caller siempre llega con un
  // idContacto ya resuelto (desde un lead), y anclar en idNumero rompía si
  // el contacto no tenía ningún T_CONTACTO_NUMERO activo. Si el contacto no
  // existe, el SP devuelve '' → ApiEmpty → contacto en blanco (modo "crear").
  Future<ContactoSimpleModel> getContactoSimplePorIdContacto(
    int idContacto,
  ) async {
    final String body = '$idContacto${sep}DS';

    final result = await _api.postSafe(ApiConstants.urlContactoLst, body);

    return switch (result) {
      ApiSuccess(:final data) =>
        ContactoSimpleModel.fromRawString(data, idContacto),
      ApiEmpty() => ContactoSimpleModel.vacio(idContacto),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'US' de CRM.CSV_CONTACTO_CUD_APP — crear/actualizar SIMPLE, mismo
  // endpoint que el task 'U' (mismo SP, otra letra de task). Envelope de 5
  // secciones separadas por sepListas (¯):
  // token(auto) ¯ datosContacto ¯ 'US' ¯ datosNumero ¯ datosCorreo ¯ datosEmpresa
  // — siempre a lo más 1 fila en numero/correo/empresa (pantalla simple).
  // idNumero(numero)/idCorreo/idEmpresaContacto van primero: 0 = fila nueva
  // (el SP la crea), con id = ya existe. Nunca toca idPais/dirección/
  // ubigeo/linkedin/prefijo(saludo) de un contacto ya existente — esos
  // campos son exclusivos de la pantalla completa y no se muestran acá.
  Future<CrudResult> guardarContactoSimple(ContactoSimple contacto) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    // ⚠️ 2026-08-03 — contacto.idNumero es MUERTO del lado del SP
    // (CSV_CONTACTO_CUD_APP, task 'US') en las 2 posiciones donde se manda
    // abajo: field1 de datosContacto y field1 de datosNumero — el SP mismo
    // lo comenta como "sin uso acá" y resuelve el número por
    // PREFIJO_PAIS+NUMERO (texto), no por id. El contacto ancla en
    // idContacto (field2 de datosContacto, 0 = crear). Se sigue mandando por
    // compatibilidad de formato, no porque el SP lo necesite.
    final datosContacto = [
      contacto.idNumero,
      contacto.idContacto,
      contacto.nombre,
      contacto.apellidoPaterno,
      contacto.apellidoMaterno,
      contacto.idTipoDocumento,
      contacto.numeroDocumento,
      contacto.idNacionalidad,
      contacto.prefijoContacto,
      _session.codUser,
      ip,
      coords,
    ].join(camp);

    final datosNumero = contacto.celular.trim().isEmpty
        ? ''
        : [contacto.idNumero, contacto.prefijoCelular, contacto.celular]
              .join(camp);

    final datosCorreo = contacto.correo.trim().isEmpty
        ? ''
        : [contacto.idCorreo, contacto.correo].join(camp);

    final datosEmpresa = contacto.razonSocial.trim().isEmpty
        ? ''
        : [
            contacto.idEmpresaContacto,
            contacto.ruc,
            contacto.razonSocial,
            contacto.cargo,
          ].join(camp);

    final String body = [
      datosContacto,
      'US',
      datosNumero,
      datosCorreo,
      datosEmpresa,
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
