//lib\features\chat\data\repositories\chat_repository_impl.dart

import 'package:app_crm/features/chat/index_chat.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _datasource;

  const ChatRepositoryImpl(this._datasource);


  @override
  Future<InfoLead> getInfoLead(int idLead) => _datasource.getInfoLead(idLead);

  @override
  Future<List<Chat>> getChats() => _datasource.getChats();

  @override
  Future<List<ChatMessage>> getChatMessages(
    int idLead, {
    String? idUltimoMensaje,
  }) => _datasource.getChatMessages(idLead, idUltimoMensaje: idUltimoMensaje);

  @override
  bool sendWhatsAppMessage(String mensaje, String idLead, String numero, String chatCab) =>
      _datasource.sendWhatsAppMessage(mensaje, idLead, numero, chatCab);
}
