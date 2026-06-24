// lib/features/chat/presentation/bloc/chat_list/chat_list_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

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

/// Aplica los filtros del panel lateral derecho.
class ChatListFiltroAvanzadoAplicado extends ChatListEvent {
  final String nombre;
  final String empresa;
  final String numero;
  final String oportunidadId;

  const ChatListFiltroAvanzadoAplicado({
    this.nombre = '',
    this.empresa = '',
    this.numero = '',
    this.oportunidadId = '',
  });

  @override
  List<Object?> get props => [nombre, empresa, numero, oportunidadId];
}

/// Limpia todos los filtros avanzados del panel lateral.
class ChatListFiltroAvanzadoLimpiado extends ChatListEvent {
  const ChatListFiltroAvanzadoLimpiado();
}

/// Evento disparado cuando llega un mensaje por WebSocket (envío o recepción).
class ChatListIncomingMessageReceived extends ChatListEvent {
  final WebSocketMessage message;
  const ChatListIncomingMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}
