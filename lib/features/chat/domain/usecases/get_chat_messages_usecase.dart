// lib\features\chat\domain\usecases\get_chat_messages_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class GetChatMessagesUseCase {
  final ChatRepository repository;
  const GetChatMessagesUseCase(this.repository);

  Future<List<ChatMessage>> call(String idLead, {String? idUltimoMensaje}) =>
      repository.getChatMessages(idLead, idUltimoMensaje: idUltimoMensaje);
}
