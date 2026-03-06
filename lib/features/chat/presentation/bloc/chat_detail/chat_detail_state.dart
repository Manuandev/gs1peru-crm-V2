// lib\features\chat\presentation\bloc\chat_detail\chat_detail_state.dart

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:equatable/equatable.dart';

abstract class ChatDetailState extends Equatable {
  const ChatDetailState();

  @override
  List<Object?> get props => [];
}

class ChatDetailInitial extends ChatDetailState {
  const ChatDetailInitial();
}

class ChatDetailLoading extends ChatDetailState {
  const ChatDetailLoading();
}

// Se está cargando más mensajes (scroll hacia arriba)
// pero ya hay mensajes visibles en pantalla
class ChatDetailLoadingMore extends ChatDetailState {
  final List<ChatMessage> messages;
  const ChatDetailLoadingMore({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatDetailSuccess extends ChatDetailState {
  final List<ChatMessage> messages;
  final bool hasMore; // false = ya no hay más mensajes que cargar

  const ChatDetailSuccess({required this.messages, this.hasMore = true});

  @override
  List<Object?> get props => [messages, hasMore];

  ChatDetailSuccess copyWith({List<ChatMessage>? messages, bool? hasMore}) {
    return ChatDetailSuccess(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class ChatDetailFailure extends ChatDetailState {
  final String message;
  const ChatDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}
