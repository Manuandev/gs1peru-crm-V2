// lib\features\chat\domain\repositories\chat_repository.dart

import 'package:app_crm/features/chat/index_chat.dart';

abstract class ChatRepository {
  Future<List<Chat>> getChats();

  Future<List<ChatMessage>> getChatMessages(String idLead, {String? idUltimoMensaje});
}
