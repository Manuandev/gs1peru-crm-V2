// lib\features\chat\domain\usecases\get_chats_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class GetChatsUseCase {
  final ChatRepository repository;
  const GetChatsUseCase(this.repository);

  Future<List<Chat>> call() => repository.getChats();
}
