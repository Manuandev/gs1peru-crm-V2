//lib\features\chat\data\datasources\remote\chat_remote_datasource.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/core/network/api_result.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<List<ChatModel>> getChats() async {
    final String body = '${_session.codUser}¯L';


    final result = await _api.postSafe(
      ApiConstants.urlChatsLst,
      body,
    );

    return switch (result) {
      ApiSuccess(:final data) => ChatModel.parseList(data),
      ApiEmpty()              => [],
      ApiNoInternet()         => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<ChatMessageModel>> getChatMessages(
    String idLead, {
    String? idUltimoMensaje, // null = primera carga
  }) async {
    final result = await _api.postSafe(
      ApiConstants.urlChatsLst,
      '$idLead¦${idUltimoMensaje ?? ''}¯LD',
    );

    return switch (result) {
      ApiSuccess(:final data) => ChatMessageModel.parseList(data),
      ApiEmpty()              => [],
      ApiNoInternet()         => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
