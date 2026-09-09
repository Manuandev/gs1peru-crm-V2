// lib/features/lead/data/datasources/remote/seguimiento_remote_datasource.dart
//
// Datasource NUEVO para Seguimiento paginado (task 'LSP' de
// CRM.CSV_LEADS_LST_APP). No toca LeadRemoteDatasource ni el controller C#
// (SPLeadLSTApp ya reenvía cualquier body por task).
//
// Body:  token ¯ codUser¦moderador¦idEstado¦curFecha¦curIdContacto¦tamanio
//                ¦fcDesde¦fcHasta¦idCampania¦idOportunidad¦idEstadoAdv¦idSubestadoAdv ¯ LSP
//   idEstado       '' = todos ; '00'/'01'/'02' = chip
//   curFecha/curId '' = primera página (o "a medias" → el SP lo trata como 1ra)
//   tamanio        lo acota el SP a 1..100 (fuera de rango → 50)
//   fcDesde/fcHasta ISO 126 ('yyyy-MM-ddTHH:mm:ss'), '' = no aplica. La app
//                  manda Desde a las 00:00:00 y Hasta a las 23:59:59.
//   idCampania/idOportunidad  '' = no aplica
//   idEstadoAdv/idSubestadoAdv  RESERVADOS — siempre '' por ahora (los maneja
//                  el chip de arriba; el SP ya los parsea con el WHERE comentado)

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class SeguimientoRemoteDatasource {
  final ApiClient _api = ApiClient();
  final SessionService _session = SessionService();

  static const int tamanioPrimera = 100;
  static const int tamanioSiguiente = 50;

  Future<SeguimientoPagina> traerPagina({
    LeadListFiltro filtro = LeadListFiltro.todos,
    String? cursorFecha,
    int? cursorIdContacto,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
  }) async {
    final camp = AppConstants.sepCampos;
    final sep = AppConstants.sepListas;

    final data = [
      _session.codUser,
      _session.isModerador ? 1 : 0,
      _codigoEstado(filtro),
      cursorFecha ?? '',
      cursorIdContacto ?? '',
      tamanio,
      _fmtFecha(fcDesde),
      _fmtFecha(fcHasta),
      idCampania ?? '',
      idOportunidad ?? '',
      '', // idEstadoAdv — reservado
      '', // idSubestadoAdv — reservado
    ].join(camp);

    final result = await _api.postSafe(
      ApiConstants.urlLeadsLst,
      '$data${sep}LSP',
    );

    return switch (result) {
      ApiSuccess(:final data) => SeguimientoPaginaModel.parse(data),
      ApiEmpty() => SeguimientoPagina.vacia,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // ISO 8601 sin milisegundos ('yyyy-MM-ddTHH:mm:ss') — formato 126 de SQL Server
  // (TRY_CONVERT(DATETIME, ..., 126)). '' si no hay fecha.
  String _fmtFecha(DateTime? d) =>
      d == null ? '' : d.toIso8601String().split('.').first;

  // '' = sin filtro. Los ids ('00'/'01'/'02') son los mismos que ya usa
  // AppSocialUtils / valoresDefecto; acá van fijos porque son el contrato del
  // SP, no un catálogo editable.
  String _codigoEstado(LeadListFiltro filtro) => switch (filtro) {
    LeadListFiltro.todos => '',
    LeadListFiltro.nuevos => '00',
    LeadListFiltro.enDesarrollo => '01',
    LeadListFiltro.propuesta => '02',
  };
}
