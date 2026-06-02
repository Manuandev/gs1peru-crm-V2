// lib\features\chat\presentation\bloc\chat_list\chat_list_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final GetChatsUseCase _getChats;
  List<Chat> _allChats = [];
  StreamSubscription<WebSocketMessage>? _messageSubscription;

  String _lastSearchQuery = '';
  ChatListFiltro _filtroActivo = ChatListFiltro.todos;

  ChatListBloc(this._getChats) : super(const ChatListInitial()) {
    on<ChatListStarted>(_onStarted);
    on<ChatListRefreshed>(_onRefreshed);
    on<ChatListSearched>(_onSearched);
    on<ChatListFiltered>(_onFiltered);
    on<ChatListIncomingMessageReceived>(_onIncomingMessageReceived);

    // Suscripción al stream de WebSocket — igual que ChatDetailBloc
    _messageSubscription = MessageDispatcher.instance.stream.listen((message) {
      if (!isClosed) {
        add(ChatListIncomingMessageReceived(message));
      }
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStarted(
    ChatListStarted event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    ChatListRefreshed event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ChatListState> emit) async {
    try {
      final chats = await _getChats();
      _allChats = chats;

      _emitFiltered(emit);
    } on AppException catch (e) {
      emit(ChatListFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const ChatListFailure('Ocurrió un error inesperado.'));
    }
  }

  void _onSearched(ChatListSearched event, Emitter<ChatListState> emit) {
    _lastSearchQuery = event.query;
    _emitFiltered(emit);
  }

  void _onFiltered(ChatListFiltered event, Emitter<ChatListState> emit) {
    _filtroActivo = event.filtro;
    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<ChatListState> emit) {
    final conteos = {
      ChatListFiltro.todos: _allChats.length,
      ChatListFiltro.sinResponder: _allChats.where((c) => c.isEnviado).length,
      ChatListFiltro.enDesarrollo: _allChats
          .where((c) => c.idEstado == '01')
          .length,
    };

    var resultado = List<Chat>.from(_allChats);

    if (_filtroActivo == ChatListFiltro.sinResponder) {
      resultado = resultado.where((c) => c.isEnviado).toList();
    } else if (_filtroActivo == ChatListFiltro.enDesarrollo) {
      resultado = resultado.where((c) => c.idEstado == '01').toList();
    } 

    // filtro búsqueda
    final q = _lastSearchQuery.toLowerCase().trim();
    if (q.isNotEmpty) {
      resultado = resultado
          .where(
            (c) =>
                c.nombre.toLowerCase().contains(q) ||
                c.apellido.toLowerCase().contains(q) ||
                c.telefono.contains(q) ||
                c.nombreEmpresa.toLowerCase().contains(q),
          )
          .toList();
    }

    emit(
      ChatListSuccess(
        chats: resultado,
        filtro: _filtroActivo,
        conteos: conteos,
      ),
    );
  }

  // ── Router de mensajes entrantes ───────────────────────────────────────────

  void _onIncomingMessageReceived(
    ChatListIncomingMessageReceived event,
    Emitter<ChatListState> emit,
  ) {
    if (state is! ChatListSuccess) return;

    switch (event.message.process) {
      case 'MENSAJE_WHATSAPP':
        _handleMensajeWhatsApp(event.message, emit);
      case 'UPDATE_PANTALLA_WHATSAPP':
        _handleUpdatePantalla(event.message, emit);
      case 'UPDATE_MENSAJE_WHATSAPP':
        _handleUpdateMensaje(event.message, emit);
      default:
        break;
    }
  }

  // ── MENSAJE_WHATSAPP — Mensaje entrante del cliente ────────────────────────

  void _handleMensajeWhatsApp(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) {
    final payload = WhatsAppMessagePayload.fromMessage(message);
    if (payload == null) return;

    _updateChatInList(
      leadId: payload.leadId,
      mensaje: payload.mensaje,
      tipoMensaje: payload.tipoMensaje.isNotEmpty
          ? payload.tipoMensaje
          : 'text',
      estado: '',
      fechaHora: payload.fecha.isNotEmpty
          ? payload.fecha
          : DateTime.now().toIso8601String(),
      isEnviado:
          true, // FLG_ENTRADA = true → es mensaje de entrada (del cliente)
      idMensaje: payload.idMensaje,
      emit: emit,
    );
  }

  // ── UPDATE_PANTALLA_WHATSAPP — Confirmación de nuestro mensaje enviado ─────

  void _handleUpdatePantalla(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) {
    final payload = UpdatePantallaWhatsAppPayload.fromMessage(message);
    if (payload == null) return;

    _updateChatInList(
      leadId: payload.leadId,
      mensaje: payload.mensaje,
      tipoMensaje: payload.tipoMensaje.isNotEmpty
          ? payload.tipoMensaje
          : 'text',
      estado: 'sent',
      fechaHora: payload.hora.isNotEmpty
          ? payload.hora
          : DateTime.now().toIso8601String(),
      isEnviado:
          false, // FLG_ENTRADA = false → NO es entrada (lo enviamos nosotros)
      idMensaje: payload.idMensaje,
      emit: emit,
    );
  }

  // ── UPDATE_MENSAJE_WHATSAPP — Cambio de estado (sent → delivered → read) ──

  void _handleUpdateMensaje(
    WebSocketMessage message,
    Emitter<ChatListState> emit,
  ) {
    final payload = UpdateMensajeWhatsAppPayload.fromMessage(message);
    if (payload == null) return;

    // Solo actualizar el estado del chat, no el mensaje ni la fecha
    final chats = List<Chat>.from(_allChats);
    final idx = chats.indexWhere((c) => c.idLead == payload.leadId);
    if (idx == -1) return;

    // Solo actualizar si el idMensaje coincide con el último mensaje del chat
    if (chats[idx].idMensaje == payload.idMensaje) {
      chats[idx] = chats[idx].copyWith(estado: payload.estado);
      _allChats = chats;
      _emitFiltered(emit);
    }
  }

  // ── Helper: actualizar un chat en la lista y moverlo al inicio ────────────

  void _updateChatInList({
    required int leadId,
    required String mensaje,
    required String tipoMensaje,
    required String estado,
    required String fechaHora,
    required bool isEnviado,
    required String idMensaje,
    required Emitter<ChatListState> emit,
  }) {
    final chats = List<Chat>.from(_allChats);
    final idx = chats.indexWhere((c) => c.idLead == leadId);
    if (idx == -1) return; // Lead no está en la lista, ignorar

    // Actualizar el chat con los datos del nuevo mensaje
    final updatedChat = chats[idx].copyWith(
      mensaje: mensaje,
      tipoMensaje: tipoMensaje,
      estado: estado,
      fechaHora: fechaHora,
      isEnviado: isEnviado,
      idMensaje: idMensaje,
    );

    // Remover de su posición actual y poner al inicio (como WhatsApp)
    chats.removeAt(idx);
    chats.insert(0, updatedChat);

    _allChats = chats;
    _emitFiltered(emit);
  }
}
