// lib\features\chat\presentation\bloc\chat_list\chat_list_event.dart

import 'package:app_crm/index_dependencies.dart';


abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class ChatListStarted extends ChatListEvent {
  const ChatListStarted();
}

class ChatListRefreshed extends ChatListEvent {
  const ChatListRefreshed();
}

class ChatListSearched extends ChatListEvent {
  final String query;
  const ChatListSearched(this.query);
}