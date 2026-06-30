// lib/features/chat/domain/usecases/send_chat_message_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class SendChatMessageUseCase {
  final ChatRepository _repository;

  const SendChatMessageUseCase(this._repository);

  bool call(String mensaje, String idNumero, String numero, int idChatCab) {
    return _repository.sendWhatsAppMessage(mensaje, idNumero, numero, idChatCab);
  }
}
