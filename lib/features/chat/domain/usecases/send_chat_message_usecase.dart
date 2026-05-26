// lib\features\chat\domain\usecases\send_chat_message_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class SendChatMessageUseCase {
  final ChatRepository _repository;

  const SendChatMessageUseCase(this._repository);

  bool call(String mensaje, String idLead, String numero, String chatCab) {
    return _repository.sendWhatsAppMessage(mensaje, idLead, numero, chatCab);
  }
}
