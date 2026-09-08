// lib/features/lead/data/datasources/remote/seguimiento_remote_datasource.dart
//
// Datasource NUEVO para Seguimiento paginado (task 'LSP' de
// CRM.CSV_LEADS_LST_APP). No toca LeadRemoteDatasource ni el controller C#
// (SPLeadLSTApp ya reenvía cualquier body por task).
//
// Body:  token ¯ codUser¦moderador¦idEstado¦curFecha¦curIdContacto¦tamanio ¯ LSP
//   idEstado       '' = todos ; '00'/'01'/'02' = chip
//   curFecha/curId '' = primera página (o "a medias" → el SP lo trata como 1ra)
//   tamanio        lo acota el SP a 1..100 (fuera de rango → 50)

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
