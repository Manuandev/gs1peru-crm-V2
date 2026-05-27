// lib\features\chat\domain\usecases\send_file_message_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class SendFileMessageUseCase {
  final ChatRepository _repository;

  SendFileMessageUseCase(this._repository);

  Future<bool> call({
    required String filePath,
    required String fileName,
    required String tipo,
    required String idLead,
    required String numero,
    required String chatCab,
  }) {
    return _repository.uploadAndSendFileMessage(
      filePath: filePath,
      fileName: fileName,
      tipo: tipo,
      idLead: idLead,
      numero: numero,
      chatCab: chatCab,
    );
  }
}
