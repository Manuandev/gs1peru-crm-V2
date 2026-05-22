// // lib\features\prospectos\data\datasources\remote\prospecto_remote_datasource.dart

// import 'package:app_crm/core/index_core.dart';
// import 'package:app_crm/core/network/api_result.dart';
// import 'package:app_crm/features/prospectos/index_prospectos.dart';

// class ProspectoRemoteDatasource {
//   final ApiClient _api = ApiClient();
//   final _session = SessionService();

//   Future<List<ProspectoModel>> getProspectos() async {
//     final String body = '${_session.codUser}¯L';

//     final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

//     return switch (result) {
//       ApiSuccess(:final data) => ProspectoModel.parseList(data),
//       ApiEmpty() => [],
//       ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
//       ApiError(:final message) => throw AppException(message),
//     };
//   }
// }
