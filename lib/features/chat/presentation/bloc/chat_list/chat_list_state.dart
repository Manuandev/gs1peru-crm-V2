// lib\features\chat\presentation\bloc\chat_list\chat_list_state.dart

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:equatable/equatable.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {
  const ChatListInitial();
}

class ChatListLoading extends ChatListState {
  const ChatListLoading();
}

class ChatListSuccess extends ChatListState {
  final List<Chat> chats;
  const ChatListSuccess({required this.chats});

  @override
  List<Object?> get props => [chats];
}

class ChatListFailure extends ChatListState {
  final String message;
  const ChatListFailure(this.message);

  @override
  List<Object?> get props => [message];
}
