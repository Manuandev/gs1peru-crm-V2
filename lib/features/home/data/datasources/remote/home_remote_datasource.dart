// lib/features/home/data/datasources/remote/home_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  Future<HomeModel> getData() async {
    final esEquipo =
        _session.isModerador &&
        FiltroCubit.instance.state.vista == FiltroVista.miEquipo;
    final String body =
        '${[_session.codUser, esEquipo ? 1 : 0].join(camp)}${sep}L';

    final result = await _api.postSafe(ApiConstants.urlHomeLst, body);

    return switch (result) {
      ApiSuccess(:final data) => HomeModel.parse(data),
      ApiEmpty() => const HomeModel(
        totLeadsNuevos: 0,
        totLeadsDesarrollo: 0,
        totPropuestas: 0,
        totSeguimientos: 0,
        totCobranza: 0,
        totConversaciones: 0,
        totNotificaciones: 0,
        totSolicitudesSinValidar: 0,
        prioridades: [],
        prospectos: [],
        asesores: [],
      ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<Notificacion>> getNotifications() async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(camp)}${sep}LS';

    final result = await _api.postSafe(ApiConstants.urlNotificacionesLst, body);

    return switch (result) {
      ApiSuccess(:final data) => NotificacionModel.parseList(data),
      ApiEmpty() => const <Notificacion>[],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Se llama al entrar a la pantalla de notificaciones — marca como leídas
  // TODAS las notificaciones del usuario (CSV_NOTIFICACIONES_CUD_APP, tarea 'LE').
  Future<CrudResult> marcarNotificacionesLeidas() async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final String body = [_session.codUser, ip, coords].join(camp);

    final result = await _api.postSafe(
      ApiConstants.urlNotificacionesCud,
      '$body${sep}LE',
    );

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  Future<CrudResult> gestionarPrioridad(int idNumero) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final String body = [idNumero, _session.codUser, ip, coords].join(camp);

    final result = await _api.postSafe(ApiConstants.urlHomeCud, '$body${sep}G');

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }
}
