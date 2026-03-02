
import 'package:app_crm/features/chat/data/models/chat_model.dart';

abstract class IChatsRepository {
  Future<List<ChatItem>> listarChats();
}
