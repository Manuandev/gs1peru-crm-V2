// lib/features/solicitudes/data/datasources/remote/solicitud_remote_datasource.dart
//
// Estados del flujo de solicitudes (EG.ID_ESTADO_GES en CSV_SOLICITUDES_LST_APP):
//   '00' Por Completar   — faltan datos o documentos del cliente
//   '01' Por Validar     — en revisión por el asesor/supervisor
//   '02' Con Documentos  — documentación completa, pendiente de cobranza
//   '03' Lista p/Cobr.   — aprobada y lista para enviar a cobranza

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/data/models/solicitud_model.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/form/solicitud_form_cubit.dart';
import 'package:app_crm/features/solicitudes/presentation/bloc/participantes/participantes_cubit.dart';

// Id de catálogo de "RUC" en TipoDocumentoItem (SYSTABEXTER02 CODTABLA='F01') —
// mismo valor que _idTipoDocRuc en solicitud_facturacion_view.dart. Si cambia
// allá, cambiar también aquí.
const _idTipoDocRuc = '6';

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

  // Task 'U' — [CRM].[CSV_SOLICITUD_CUD_APP]. Crea (numSol vacío) o actualiza
  // (numSol existente) la cabecera + facturación + participantes de una
  // solicitud, en una sola llamada. Los archivos van aparte (task 'AR',
  // pendiente — necesita el NUMSOL que devuelve esta llamada).
  //
  // Ojo posiciones de cabecera: hoy van 42 campos con ID_CONTACTO en la
  // posición 1 (se manda vacío — el SP no lo usa en la rama de UPDATE, que es
  // la única conectada por ahora). Cuando se quite ID_CONTACTO del SP hay que
  // correr todas las posiciones un lugar acá.
  Future<CrudResult> guardarSolicitud({
    required String numSol,
    required String tipoPersona, // 'juridica' | 'natural'
    required DatosSolicitante solicitante,
    DatosFacturacion? facturacion,
    required List<ParticipanteLocal> participantes,
    required double igvPorcentaje,
    required bool esBorrador,
  }) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final esRuc = facturacion?.tipoDocId == _idTipoDocRuc;

    final idParticipanteSolicitante = participantes
        .where((p) => p.esSolicitante)
        .firstOrNull
        ?.id
        .toString();

    final dcImporte = participantes.fold(0.0, (sum, p) => sum + p.importe);
    final dcIgv = dcImporte * igvPorcentaje / 100;
    final dcImporteTotal = dcImporte + dcIgv;

    final cabecera = <String>[
      '', // 1  ID_CONTACTO — no aplica (ver nota arriba)
      '', // 2  ID_LEAD — no aplica hoy (no hay flujo de creación desde un Lead)
      numSol, // 3  NUMSOL
      tipoPersona == 'juridica' ? 'J' : 'N', // 4  COD_TIP_REGISTRO
      solicitante.tipoDocId, // 5  ID_TIP_DOC_SOL
      solicitante.numDoc, // 6  NUM_DOC_SOL
      solicitante.ruc, // 7  RUCEMPRE_SOL
      solicitante.razonSocial, // 8  NOMEMPRE_SOL
      solicitante.nacionalidadId, // 9  ID_NACION_SOL
      solicitante.sexoId, // 10 ID_SEXO_SOL
      solicitante.nombres, // 11 NOMBRES_SOL
      solicitante.apellidoPaterno, // 12 APELLIDO_P_SOL
      solicitante.apellidoMaterno, // 13 APELLIDO_M_SOL
      solicitante.cargo, // 14 CARGO_SOL
      solicitante.celular, // 15 CELULAR_SOL
      solicitante.correo, // 16 CORREO_SOL
      solicitante.solicitanteEsParticipante ? '1' : '0', // 17 IB_PARTICIPANTE_SOLICITANTE
      solicitante.facturarAlSolicitante ? '1' : '0', // 18 IB_FACTURA_SOLICITANTE
      idParticipanteSolicitante ?? '', // 19 ID_PARTICIPANTE_SOLICITANTE
      ParseUtils.orEmpty(solicitante.canalId), // 20 ID_CANAL
      solicitante.canalNombre, // 21 NOMBRE_CANAL
      facturacion?.tipoDocId ?? '', // 22 ID_TIP_DOC_FAC
      facturacion?.numDoc ?? '', // 23 NUM_DOC_FAC
      esRuc ? (facturacion?.numDoc ?? '') : '', // 24 RUCEMPRE_FAC
      esRuc ? (facturacion?.nombresRazon ?? '') : '', // 25 NOMEMPRE_FAC
      facturacion?.paisId ?? '', // 26 ID_NACION_FAC (el SP reusa esta misma variable para ID_PAIS)
      esRuc ? '' : (facturacion?.nombresRazon ?? ''), // 27 NOMBRES_FAC
      esRuc ? '' : (facturacion?.apellidoPaterno ?? ''), // 28 APELLIDO_P_FAC
      esRuc ? '' : (facturacion?.apellidoMaterno ?? ''), // 29 APELLIDO_M_FAC
      '', // 30 CARGO_FAC — el SP no lo usa en ningún INSERT/UPDATE
      facturacion?.celular ?? '', // 31 CELULAR_FAC
      facturacion?.correo ?? '', // 32 CORREO_FAC
      facturacion?.direccion ?? '', // 33 DIRECCION_FAC
      '', // 34 UBIGEO_FAC — sin selector en la UI todavía
      facturacion?.monedaId ?? '', // 35 ID_MONEDA
      dcImporte.toStringAsFixed(2), // 36 DC_IMPORTE
      dcIgv.toStringAsFixed(2), // 37 DC_IGV
      dcImporteTotal.toStringAsFixed(2), // 38 DC_IMPORTE_TOTAL
      esBorrador ? '1' : '0', // 39 IB_BORRADOR
      _session.codUser, // 40 ID_USUARIO
      ip, // 41 IP_USUARIO
      coords, // 42 LL_USUARIO
    ].join(AppConstants.sepCampos);

    final detalle = participantes.map((p) {
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
    }).join(AppConstants.sepRegistros);

    final body = [cabecera, detalle, 'U'].join(AppConstants.sepListas);

    final result = await _api.postSafe(ApiConstants.urlSolicitudesCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }
}
