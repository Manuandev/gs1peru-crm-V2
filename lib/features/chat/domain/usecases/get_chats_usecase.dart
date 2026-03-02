import 'package:app_crm/features/chat/data/models/chat_model.dart';
import 'package:app_crm/features/chat/domain/repositories/i_chats_repository.dart';

class GetChatsUsecase {
  final IChatsRepository _repository;

  const GetChatsUsecase({required IChatsRepository repository})
      : _repository = repository;

  Future<List<ChatItem>> execute() => _repository.listarChats();
}