
import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/network/api_client.dart';
import 'package:app_crm/core/services/session_service.dart';
import 'package:app_crm/features/chat/data/models/chat_model.dart';

class ChatsRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();


  Future<List<ChatItem>> listarChats() async {

    final String body = '${_session.codUser}¯L';

    final String raw = await _api.postJsonGetText(
      ApiConstants.urlChatsLst,
      body,
    );

    if (raw.isEmpty) {
      throw ChatsException(
        'No se pudo conectar al servidor. Verifica tu conexión a Internet.',
      );
    }

    try {
      return ChatItem.parseChatItemList(raw);
    } on FormatException catch (e) {
      throw ChatsException(e.message);
    }
  }
}

class ChatsException implements Exception {
  final String message;
  const ChatsException(this.message);

  @override
  String toString() => message;
}
