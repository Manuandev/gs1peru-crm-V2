import 'package:app_crm/features/chat/data/datasources/remote/chats_remote_datasource.dart';
import 'package:app_crm/features/chat/data/models/chat_model.dart';
import 'package:app_crm/features/chat/domain/repositories/i_chats_repository.dart';

class ChatsRepository implements IChatsRepository {
  final ChatsRemoteDatasource _remote;

  ChatsRepository({required ChatsRemoteDatasource remote}) : _remote = remote;

  @override
  Future<List<ChatItem>> listarChats() => _remote.listarChats();
}
