// lib/features/chat/presentation/bloc/chat_list/chat_list_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/chat/index_chat.dart';

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

/// Contadores globales calculados siempre sobre la lista completa (_allChats),
/// independientemente del chip o filtro avanzado activo.
class ContadoresChat extends Equatable {
  final int sinResponder;   // direccionMensaje == 'CLI'
  final int derivadasPorIA; // isDerivadoIA == true
  final int conPropuesta;   // idEstadoEfectivo == '02'
  final int enCobranza;     // idEstado == '05'

  const ContadoresChat({
    this.sinResponder = 0,
    this.derivadasPorIA = 0,
    this.conPropuesta = 0,
    this.enCobranza = 0,
  });

  @override
  List<Object?> get props => [sinResponder, derivadasPorIA, conPropuesta, enCobranza];
}

class ChatListSuccess extends ChatListState {
  final ContadoresChat contadores;
  final List<Chat> conversaciones;
  final ChatListFiltro filtro;
  final Map<ChatListFiltro, int> conteos;

  // Filtros avanzados activos (panel lateral)
  final String filtroNombre;
  final String filtroEmpresa;
  final String filtroNumero;
  final String filtroCampaniaId;
  final String filtroOportunidadId;

  bool get tieneFiltroAvanzado =>
      filtroNombre.isNotEmpty ||
      filtroEmpresa.isNotEmpty ||
      filtroNumero.isNotEmpty ||
      filtroCampaniaId.isNotEmpty ||
      filtroOportunidadId.isNotEmpty;

  const ChatListSuccess({
    required this.contadores,
    required this.conversaciones,
    this.filtro = ChatListFiltro.todos,
    this.conteos = const {},
    this.filtroNombre = '',
    this.filtroEmpresa = '',
    this.filtroNumero = '',
    this.filtroCampaniaId = '',
    this.filtroOportunidadId = '',
  });

  @override
  List<Object?> get props => [
    contadores,
    conversaciones,
    filtro,
    conteos,
    filtroNombre,
    filtroEmpresa,
    filtroNumero,
    filtroCampaniaId,
    filtroOportunidadId,
  ];
}

class ChatListError extends ChatListState {
  final String message;
  const ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}
