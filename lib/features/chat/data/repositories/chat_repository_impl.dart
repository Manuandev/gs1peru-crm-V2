//lib\features\chat\data\repositories\chat_repository_impl.dart

import 'package:app_crm/features/chat/index_chat.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _datasource;

  const ChatRepositoryImpl(this._datasource);

  @override
  Future<List<Chat>> getChats() => _datasource.getChats();

  @override
  Future<List<ChatMessage>> getChatMessages(
    String idLead, {
    String? idUltimoMensaje,
  }) => _datasource.getChatMessages(idLead, idUltimoMensaje: idUltimoMensaje);
}
