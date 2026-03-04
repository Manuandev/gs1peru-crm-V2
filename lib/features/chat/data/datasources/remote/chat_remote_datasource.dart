//lib\features\chat\data\datasources\remote\chat_remote_datasource.dart


import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();


  Future<List<ChatModel>> getChats() async {

    final String body = '${_session.codUser}¯L';

    final String raw = await _api.postJsonGetText(
      ApiConstants.urlChatsLst,
      body,
    );

    if (raw.isEmpty) {
      throw AppException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return ChatModel.parseList(raw);
    } on FormatException catch (e) {
      throw AppException(e.message);
    }
  }
}
