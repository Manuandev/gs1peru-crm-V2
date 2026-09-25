// lib/features/home/data/datasources/remote/home_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  static const HomeModel _homeVacio = HomeModel(
    totLeadsNuevos: 0,
    totLeadsDesarrollo: 0,
    totPropuestas: 0,
    totSeguimientos: 0,
    totCobranza: 0,
    totConversaciones: 0,
    totNotificaciones: 0,
    totSolicitudesSinValidar: 0,
    totSeguimientosActivos: 0,
    prioridades: [],
    prospectos: [],
    asesores: [],
  );

  // Task 'L' de CRM.CSV_HOME_LST_APP.
  // Body: codUser ¦ esEquipo ¦ idUnidad — contadores, prioridades, prospectos
  // y asesores de la unidad de negocio activa (2026-09-25). Sin unidades
  // asignadas no se llama al SP: todo en 0.
  Future<HomeModel> getData() async {
    if (!_session.tieneUnidades) return _homeVacio;

    final esEquipo =
        _session.isModerador &&
        FiltroCubit.instance.state.vista == FiltroVista.miEquipo;
    final String body =
        '${[_session.codUser, esEquipo ? 1 : 0, _session.idUnidadBody].join(camp)}${sep}L';

    final result = await _api.postSafe(ApiConstants.urlHomeLst, body);

    return switch (result) {
      ApiSuccess(:final data) => HomeModel.parse(data),
      ApiEmpty() => _homeVacio,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Notificaciones paginadas por keyset (task 'LS' de
  // CRM.CSV_NOTIFICACIONES_LST_APP, reescrito 2026-09-10).
  //
  // Body: codUser ¦ moderador ¦ filtro ¦ curFecha(126) ¦ curId ¦ tamanio
  //       ¦ idUnidad
  //   filtro    '' = todas ; 'ACT' | 'AIA' | 'CHAT'
  //   curFecha/curId  '' = primera página (el SP trata "a medias" como 1ra)
  //   tamanio   lo acota el SP a 1..100 (fuera de rango → 50)
  //   idUnidad  unidad de negocio activa (2026-09-25) — solo notificaciones
  //             cuya negociación (id de referencia) es de una campaña de esa
  //             unidad. Sin unidades asignadas no se llama al SP.
  static const int tamanioPrimera = 40;
  static const int tamanioSiguiente = 30;

  Future<NotificacionesPagina> getNotifications({
    FiltroNotificacion filtro = FiltroNotificacion.todas,
    String? cursorFecha,
    int? cursorId,
    required int tamanio,
  }) async {
    if (!_session.tieneUnidades) return NotificacionesPagina.vacia;

    final data = [
      _session.codUser,
      _session.isModerador ? 1 : 0,
      filtro.codigoSp,
      cursorFecha ?? '',
      cursorId ?? '',
      tamanio,
      _session.idUnidadBody,
    ].join(camp);

    final result = await _api.postSafe(
      ApiConstants.urlNotificacionesLst,
      '$data${sep}LS',
    );

    return switch (result) {
      ApiSuccess(:final data) => NotificacionesPaginaModel.parse(data),
      ApiEmpty() => NotificacionesPagina.vacia,
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Se llama al entrar a la pantalla de notificaciones — marca como leídas
  // las notificaciones del usuario de la unidad de negocio ACTIVA
  // (CSV_NOTIFICACIONES_CUD_APP, tarea 'LE'). Las de otras unidades quedan sin
  // leer hasta que las vea con esa unidad (2026-09-25).
  // Body: codUser ¦ ip ¦ coords ¦ idUnidad
  Future<CrudResult> marcarNotificacionesLeidas() async {
    if (!_session.tieneUnidades) return const CrudEmpty();

    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final String body = [
      _session.codUser,
      ip,
      coords,
      _session.idUnidadBody,
    ].join(camp);

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
