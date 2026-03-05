// lib\features\chat\domain\usecases\get_chat_messages_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class GetMessagesUseCase {
  final ChatRepository repository;
  const GetMessagesUseCase(this.repository);

  Future<List<ChatMessage>> call({
    required String idLead,
    String? idUltimoMensaje,
  }) => repository.getChatMessages(idLead, idUltimoMensaje: idUltimoMensaje);
}
