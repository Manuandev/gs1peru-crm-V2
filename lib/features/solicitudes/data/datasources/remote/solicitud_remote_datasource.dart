// lib/features/solicitudes/data/datasources/remote/solicitud_remote_datasource.dart
//
// Estados del flujo de solicitudes (EG.ID_ESTADO_GES en CSV_SOLICITUDES_LST_APP):
//   '00' Por Completar   — faltan datos o documentos del cliente
//   '01' Por Validar     — en revisión por el asesor/supervisor
//   '02' Con Documentos  — documentación completa, pendiente de cobranza
//   '03' Lista p/Cobr.   — aprobada y lista para enviar a cobranza

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  Future<List<SolicitudModel>> getSolicitudes() async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(AppConstants.sepCampos)}${AppConstants.sepListas}LS';

    final result = await _api.postSafe(ApiConstants.urlSolicitudesLst, body);

    return switch (result) {
      ApiSuccess(:final data) => SolicitudModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'DT' — [CRM].[CSV_SOLICITUD_LST_APP] (misma SP que 'LS', endpoint
  // urlSolicitudesLst). Trae solicitante + facturación + participantes +
  // archivos de una solicitud ya guardada, dado su NUMSOL — usado para
  // rehidratar el wizard al entrar por "Editar ficha"/"Continuar".
  Future<SolicitudDetalleModel> getSolicitudDetalle(String numSol) async {
    final body = '$numSol${AppConstants.sepListas}DT';

    final result = await _api.postSafe(ApiConstants.urlSolicitudesLst, body);

    return switch (result) {
      ApiSuccess(:final data) => SolicitudDetalleModel.fromRawString(data),
      ApiEmpty() => throw const AppException('La solicitud no existe.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'DV' — [CRM].[CSV_SOLICITUD_LST_APP] (misma SP, endpoint
  // urlSolicitudesLst que 'LS'/'DT'). A diferencia de 'DT' (solo ids de
  // catálogo, pensada para rehidratar el wizard), 'DV' resuelve las
  // descripciones en el propio SP y trae también participantes/historial —
  // pensada para SolicitudDetalleView (solo lectura), no para el formulario.
  Future<SolicitudDetalle> getDetalleSolicitud(String numSol) async {
    final body = '$numSol${AppConstants.sepListas}DV';

    final result = await _api.postSafe(ApiConstants.urlSolicitudesLst, body);

    return switch (result) {
      ApiSuccess(:final data) => SolicitudDetalleRealModel.fromRawString(data),
      ApiEmpty() => throw const AppException('La solicitud no existe.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'U' — [CRM].[CSV_SOLICITUD_CUD_APP]. Crea (numSol vacío) o actualiza
  // (numSol existente) la cabecera + facturación + participantes de una
  // solicitud, en una sola llamada. Los archivos van aparte (task 'AR',
  // pendiente — necesita el NUMSOL que devuelve esta llamada).
  //
  // Cabecera: 43 campos, ID_LEAD es field1 (el SP ya no recibe ID_CONTACTO).
  // field42 (comprobanteId) y field43 (nacionalidadId de facturación) se
  // agregaron el 2026-07-16 — antes el datasource solo mandaba 41 campos y
  // el SP nunca recibía @ID_TIPO_COMPROBANTE_FAC/@ID_NACIONALIDAD_FAC (bug
  // real: comprobante y nacionalidad de facturación no sobrevivían a
  // reabrir la solicitud). Ver CLAUDE.md del feature.
  Future<CrudResult> guardarSolicitud({
    required String numSol,
    required String
    idLead, // solo aplica al crear (numSol vacío) desde una negociación
    required String tipoPersona, // 'juridica' | 'natural'
    required DatosSolicitante solicitante,
    DatosFacturacion? facturacion,
    required List<ParticipanteLocal> participantes,
    required double igvPorcentaje,
    required bool esBorrador,
    // Descuento de la negociación de origen (0 si no viene de una) — se
    // resta del importe bruto ANTES del IGV. No viaja como columna propia
    // al backend, el SP no tiene una — se refleja directo en DC_IMPORTE/
    // DC_IGV/DC_IMPORTE_TOTAL (ver CLAUDE.md).
    double descuento = 0,
    // Id real de "RUC" en TipoDocumentoItem (CatalogsBloc.valoresDefecto.
    // idTipoDocRuc) — el datasource no tiene acceso a CatalogsBloc (capa de
    // presentación), así que el caller lo resuelve y lo pasa acá. Nunca
    // volver a hardcodear este id.
    required String idTipoDocRuc,
  }) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final esRuc = facturacion?.tipoDocId == idTipoDocRuc;

    final idParticipanteSolicitante = participantes
        .where((p) => p.esSolicitante)
        .firstOrNull
        ?.id
        .toString();

    final dcImporteBruto = participantes.fold(0.0, (sum, p) => sum + p.importe);
    final dcImporte = (dcImporteBruto - descuento).clamp(0.0, double.infinity);
    final dcIgv = dcImporte * igvPorcentaje / 100;
    final dcImporteTotal = dcImporte + dcIgv;

    final cabecera = <String>[
      idLead, // 1  ID_LEAD — solo se usa en la rama de creación (numSol vacío)
      numSol, // 2  NUMSOL
      tipoPersona == 'juridica' ? 'J' : 'N', // 3  COD_TIP_REGISTRO
      solicitante.tipoDocId, // 4  ID_TIP_DOC_SOL
      solicitante.numDoc, // 5  NUM_DOC_SOL
      solicitante.ruc, // 6  RUCEMPRE_SOL
      solicitante.razonSocial, // 7  NOMEMPRE_SOL
      solicitante.nacionalidadId, // 8  ID_NACION_SOL
      solicitante.sexoId, // 9  ID_SEXO_SOL
      solicitante.nombres, // 10 NOMBRES_SOL
      solicitante.apellidoPaterno, // 11 APELLIDO_P_SOL
      solicitante.apellidoMaterno, // 12 APELLIDO_M_SOL
      solicitante.cargo, // 13 CARGO_SOL
      solicitante.celular, // 14 CELULAR_SOL
      solicitante.correo, // 15 CORREO_SOL
      solicitante.solicitanteEsParticipante
          ? '1'
          : '0', // 16 IB_PARTICIPANTE_SOLICITANTE
      solicitante.facturarAlSolicitante
          ? '1'
          : '0', // 17 IB_FACTURA_SOLICITANTE
      idParticipanteSolicitante ?? '', // 18 ID_PARTICIPANTE_SOLICITANTE
      ParseUtils.orEmpty(solicitante.canalId), // 19 ID_CANAL
      solicitante.canalNombre, // 20 NOMBRE_CANAL
      facturacion?.tipoDocId ?? '', // 21 ID_TIP_DOC_FAC
      facturacion?.numDoc ?? '', // 22 NUM_DOC_FAC
      esRuc ? (facturacion?.numDoc ?? '') : '', // 23 RUCEMPRE_FAC
      esRuc ? (facturacion?.nombresRazon ?? '') : '', // 24 NOMEMPRE_FAC
      facturacion?.paisId ??
          '', // 25 ID_NACION_FAC (el SP reusa esta misma variable para ID_PAIS)
      esRuc ? '' : (facturacion?.nombresRazon ?? ''), // 26 NOMBRES_FAC
      esRuc ? '' : (facturacion?.apellidoPaterno ?? ''), // 27 APELLIDO_P_FAC
      esRuc ? '' : (facturacion?.apellidoMaterno ?? ''), // 28 APELLIDO_M_FAC
      '', // 29 CARGO_FAC — el SP no lo usa en ningún INSERT/UPDATE
      facturacion?.celular ?? '', // 30 CELULAR_FAC
      facturacion?.correo ?? '', // 31 CORREO_FAC
      facturacion?.direccion ?? '', // 32 DIRECCION_FAC
      '', // 33 UBIGEO_FAC — sin selector en la UI todavía
      facturacion?.monedaId ?? '', // 34 ID_MONEDA
      dcImporte.toStringAsFixed(2), // 35 DC_IMPORTE
      dcIgv.toStringAsFixed(2), // 36 DC_IGV
      dcImporteTotal.toStringAsFixed(2), // 37 DC_IMPORTE_TOTAL
      esBorrador ? '1' : '0', // 38 IB_BORRADOR
      _session.codUser, // 39 ID_USUARIO
      ip, // 40 IP_USUARIO
      coords, // 41 LL_USUARIO
      facturacion?.comprobanteId ?? '', // 42 ID_TIPO_COMPROBANTE_FAC
      facturacion?.nacionalidadId ?? '', // 43 ID_NACIONALIDAD_FAC
    ].join(AppConstants.sepCampos);

    final detalle = participantes
        .map((p) {
          final igv = p.importe * igvPorcentaje / 100;
          return [
            p.id.toString(), // ID
            p.tipoDocId, // ID_TIP_DOC
            p.numDoc, // NUM_DOC
            p.nacionalidadId, // ID_NACION
            p.nombres, // NOMBRES
            p.apellidoPaterno, // APELLIDO_P
            p.apellidoMaterno, // APELLIDO_M
            p.correo, // CORREO
            p.celular, // CELULAR
            p.cargo, // CARGO
            p.importe.toStringAsFixed(2), // IMPORTE
            igv.toStringAsFixed(2), // IGV
            '1', // IB_IGV — siempre true, no hay switch en la UI para desactivarlo
            p.tipoParticipante, // ID_TIP_PARTICIPANTE (sin catálogo real, ver CLAUDE.md)
          ].join(AppConstants.sepCampos);
        })
        .join(AppConstants.sepRegistros);

    final body = [cabecera, detalle, 'U'].join(AppConstants.sepListas);

    final result = await _api.postSafe(ApiConstants.urlSolicitudesCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  // Task 'AR' — [CRM].[CSV_SOLICITUD_CUD_APP] vía SPSolicitudCUDAppArchivos.
  // Sube un archivo (voucher/OC) ya con el NUMSOL confirmado (viene de la
  // respuesta de guardarSolicitud). Chunks de 2MB, mismo patrón que
  // ChatRemoteDatasource.uploadAndSendFileMessage. Contrato acordado con
  // backend: cabecera = NUMSOL¦ID_USUARIO¦IP_USUARIO¦LL_USUARIO,
  // detalle = TIPO¦NOMBRE¦EXT (sin id — el GUID lo genera el backend).
  Future<bool> guardarArchivo({
    required String numSol,
    required String tipo, // 'voucher' | 'oc'
    required String fileName, // sin extensión
    required String fileExt,
    required List<int> fileBytes,
  }) async {
    if (fileBytes.isEmpty) return false;

    // El backend arma una ruta de archivo en disco con estos dos valores tal
    // cual — sanear acá evita mandar separadores de ruta ("..", "/", "\") que
    // el nombre de un archivo local podría llegar a traer.
    final fileNameSeguro = _sanitizarNombreArchivo(fileName);
    final fileExtSeguro = _sanitizarExtensionArchivo(fileExt);

    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();
    final token = _session.token;

    final cabecera = [
      numSol,
      _session.codUser,
      ip,
      coords,
    ].join(AppConstants.sepCampos);
    final detalle = [
      tipo,
      fileNameSeguro,
      fileExtSeguro,
    ].join(AppConstants.sepCampos);

    const chunkSize = 2 * 1024 * 1024;
    final totalSize = fileBytes.length;
    final totalChunks = (totalSize / chunkSize).ceil();
    final urlUpload = ApiConstants.urlSolicitudesCudArchivos;

    for (var i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;
      final end = (start + chunkSize > totalSize)
          ? totalSize
          : start + chunkSize;
      final chunkBytes = fileBytes.sublist(start, end);

      final dataString = [
        token,
        cabecera,
        detalle,
        'AR',
        i + 1,
        totalChunks,
      ].join(AppConstants.sepListas);

      final result = await _api.postMultipart(
        url: urlUpload,
        fields: {'data': dataString},
        fileFieldName: 'files',
        fileBytes: chunkBytes,
        fileName: '$fileNameSeguro.$fileExtSeguro',
        headers: {'Token': token},
      );

      if (result.isEmpty) return false;
      final datos = result.split(AppConstants.sepCampos);
      if (datos[0] != 'OK') return false;
    }

    return true;
  }

  // Quita separadores de ruta y ".." — el backend arma la ruta física del
  // archivo concatenando este valor directo, sin volver a validarlo.
  String _sanitizarNombreArchivo(String nombre) {
    final sinRuta = nombre
        .replaceAll(RegExp(r'[\\/]'), '_')
        .replaceAll('..', '_')
        .trim();
    return sinRuta.isEmpty ? 'archivo' : sinRuta;
  }

  // La extensión solo debe traer letras/números (pdf, jpg, docx, etc.).
  String _sanitizarExtensionArchivo(String ext) {
    final limpio = ext.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return limpio.isEmpty ? 'bin' : limpio;
  }
}
