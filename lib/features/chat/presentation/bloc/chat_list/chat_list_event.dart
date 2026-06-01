// lib\features\chat\presentation\bloc\chat_list\chat_list_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';

enum ChatListFiltro { todos, sinResponder, enDesarrollo, propuesta }

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

  @override
  List<Object?> get props => [query];
}

class ChatListFiltered extends ChatListEvent {
  final ChatListFiltro filtro;
  const ChatListFiltered(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// Evento disparado cuando llega un mensaje por WebSocket (envío o recepción).
class ChatListIncomingMessageReceived extends ChatListEvent {
  final WebSocketMessage message;
  const ChatListIncomingMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
