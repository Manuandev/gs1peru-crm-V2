// lib\features\chat\presentation\bloc\chat_detail\chat_detail_bloc.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetMessagesUseCase _getMessages;

  List<ChatMessage> _allMessages = [];
  String _idLead = '';
  String? _idUltimoMensaje; // null = primera carga

  ChatDetailBloc(this._getMessages) : super(const ChatDetailInitial()) {
    on<ChatDetailStarted>(_onStarted);
    on<ChatDetailRefreshed>(_onRefreshed);
    on<ChatDetailLoadMore>(_onLoadMore);
  }

  Future<void> _onStarted(
    ChatDetailStarted event,
    Emitter<ChatDetailState> emit,
  ) async {
    _idLead = event.idLead;
    _allMessages = [];
    _idUltimoMensaje = null;

    emit(const ChatDetailLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    ChatDetailRefreshed event,
    Emitter<ChatDetailState> emit,
  ) async {
    _allMessages = [];
    _idUltimoMensaje = null;
    emit(const ChatDetailLoading());
    await _loadData(emit);
  }

  Future<void> _onLoadMore(
    ChatDetailLoadMore event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailSuccess) return;
    if (!(state as ChatDetailSuccess).hasMore) return;

    emit(ChatDetailLoadingMore(messages: _allMessages));
    await _loadData(emit, isLoadMore: true);
  }

  Future<void> _loadData(
    Emitter<ChatDetailState> emit, {
    bool isLoadMore = false,
  }) async {
    try {
      final newMessages = await _getMessages(
        idLead: _idLead,
        idUltimoMensaje: _idUltimoMensaje,
      );

      if (newMessages.isNotEmpty) {
        // Guardamos el ID del mensaje más antiguo para la siguiente paginación
        _idUltimoMensaje = newMessages.first.idMensaje;

        // Si es paginación, los nuevos van ANTES (son más antiguos)
        _allMessages = isLoadMore
            ? [...newMessages, ..._allMessages]
            : newMessages;
      }

      emit(
        ChatDetailSuccess(
          messages: _allMessages,
          hasMore: newMessages.isNotEmpty,
        ),
      );
    } on AppException catch (e) {
      emit(ChatDetailFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(const ChatDetailFailure('Ocurrió un error inesperado.'));
    }
  }
}
