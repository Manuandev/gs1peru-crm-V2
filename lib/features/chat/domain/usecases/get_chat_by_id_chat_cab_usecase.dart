// lib/features/chat/domain/usecases/get_chat_by_id_chat_cab_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class GetChatByIdChatCabUseCase {
  final ChatRepository repository;
  const GetChatByIdChatCabUseCase(this.repository);

  Future<Chat?> call(int idChatCab) => repository.getChatByIdChatCab(idChatCab);
}
