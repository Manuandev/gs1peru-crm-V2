// lib\features\chat\domain\repositories\chat_repository.dart

import 'package:app_crm/features/chat/index_chat.dart';

abstract class ChatRepository {
  Future<InfoLead> getInfoLead(int idLead);
  Future<List<Chat>> getChats();

  Future<List<ChatMessage>> getChatMessages(
    int idLead, {
    String? idUltimoMensaje,
  });
}
