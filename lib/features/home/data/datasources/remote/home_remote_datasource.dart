// lib\features\home\data\datasources\remote\home_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<HomeModel> getData() async {
    final String body = '${_session.codUser}¦${_session.isModerador ? 1 : 0}¯L';

    final result = await _api.postSafe(ApiConstants.urlHomeLst, body);

    return switch (result) {
      ApiSuccess(:final data) => HomeModel.parse(data),
      ApiEmpty() => const HomeModel(
        totConversaciones: 0,
        totProspectos: 0,
        totPropuestas: 0,
        totCobranza: 0,
        totLeadsNuevos: 0,
        totLeadsDesarrollo: 0,
        totNotificaciones: 0,
        prioridades: [],
        prospectos: [],
      ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message), 
    };
  }

  Future<NotificationModel> getNotifications() async {
    final String body = '${_session.codUser}¦${_session.isModerador ? 1 : 0}¯LN';

    final result = await _api.postSafe(ApiConstants.urlHomeLst, body);

    return switch (result) {
      ApiSuccess(:final data) => NotificationModel.parse(data),
      ApiEmpty() => const NotificationModel(
        totNotificaciones: 0,
        totLeadsNuevos: 0,
        totLeadsReasignados: 0,
        totRecordatorios: 0,
        leadsNuevos: [],
        leadsReasignados: [],
        recordatorios: [],
      ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
