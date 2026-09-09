// lib/features/chat/presentation/bloc/chat_list/chat_list_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

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

/// Reingreso a la pantalla desde el menú: recarga la lista y devuelve TODOS
/// los filtros (chip, búsqueda y panel avanzado) a su estado inicial.
/// A diferencia de [ChatListRefreshed] (pull-to-refresh / reintento), que solo
/// recarga datos y conserva el filtro activo — necesario porque `ChatListBloc`
/// es global y no muere al salir de la pantalla.
class ChatListReset extends ChatListEvent {
  const ChatListReset();
}

/// Recarga la lista desde la API sin emitir estado de carga (sin flash).
/// Usar al regresar del detalle de chat.
class ChatListSilentRefreshed extends ChatListEvent {
  const ChatListSilentRefreshed();
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
  final String campaniaId;
  final String oportunidadId;

  const ChatListFiltroAvanzadoAplicado({
    this.nombre = '',
    this.empresa = '',
    this.numero = '',
    this.campaniaId = '',
    this.oportunidadId = '',
  });

  @override
  List<Object?> get props => [
    nombre,
    empresa,
    numero,
    campaniaId,
    oportunidadId,
  ];
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

/// Parcha el [Chat] que contiene ese lead en memoria tras edición exitosa.
class ChatListLeadUpdated extends ChatListEvent {
  final Negociacion negociacion;
  const ChatListLeadUpdated(this.negociacion);

  @override
  List<Object?> get props => [negociacion];
}
