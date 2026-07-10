// lib/features/solicitudes/data/datasources/remote/solicitud_remote_datasource.dart
//
// Estados del flujo de solicitudes (EG.ID_ESTADO_GES en CSV_SOLICITUDES_LST_APP):
//   '00' Por Completar   — faltan datos o documentos del cliente
//   '01' Por Validar     — en revisión por el asesor/supervisor
//   '02' Con Documentos  — documentación completa, pendiente de cobranza
//   '03' Lista p/Cobr.   — aprobada y lista para enviar a cobranza

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/data/models/solicitud_model.dart';

class SolicitudRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

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
}
