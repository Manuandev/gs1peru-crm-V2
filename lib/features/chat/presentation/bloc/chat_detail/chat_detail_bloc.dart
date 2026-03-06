// lib\features\chat\presentation\bloc\chat_detail\chat_detail_bloc.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetChatMessagesUseCase _getChatMessages;

  ChatDetailBloc(this._getChatMessages) : super(const ChatDetailInitial()) {
    on<ChatDetailStarted>(_onStarted);
    on<ChatDetailRefreshed>(_onRefreshed);
    on<ChatDetailMoreMessagesLoaded>(_onMoreMessagesLoaded);
    on<ChatDetailTextMessageSent>(_onTextMessageSent);
    on<ChatDetailAudioMessageSent>(_onAudioMessageSent);
    on<ChatDetailFileMessageSent>(_onFileMessageSent);
  }

  // ── Carga inicial ──────────────────────────────────────────────────────────

  Future<void> _onStarted(
    ChatDetailStarted event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(const ChatDetailLoading());
    await _loadMessages(event.idLead, emit);
  }

  Future<void> _onRefreshed(
    ChatDetailRefreshed event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(const ChatDetailLoading());
    await _loadMessages(event.idLead, emit);
  }

  Future<void> _loadMessages(
    String idLead,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      final messages = await _getChatMessages(idLead);
      emit(ChatDetailSuccess(messages: messages, hasMore: messages.isNotEmpty));
    } on AppException catch (e) {
      // ✅ FIX: error real → estado de error, no éxito vacío
      emit(ChatDetailFailure(e.message));
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      // ✅ FIX: error inesperado → estado de error
      emit(const ChatDetailFailure('Ocurrió un error inesperado.'));
    }
  }

  // ── Paginación (scroll hacia arriba) ──────────────────────────────────────

  Future<void> _onMoreMessagesLoaded(
    ChatDetailMoreMessagesLoaded event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailSuccess) return;

    final currentState = state as ChatDetailSuccess;
    if (!currentState.hasMore) return; // ← ya no hay más, ignorar

    emit(ChatDetailLoadingMore(messages: currentState.messages));

    try {
      final newMessages = await _getChatMessages(
        event.idLead,
        idUltimoMensaje: event.idUltimoMensaje,
      );

      emit(
        ChatDetailSuccess(
          messages: [...newMessages, ...currentState.messages],
          hasMore: newMessages.isNotEmpty, // ← false si servidor devolvió vacío
        ),
      );
    } catch (_) {
      // Falla silenciosa — no mostrar error, bloquear futuros intentos
      emit(currentState.copyWith(hasMore: false));
    }
  }

  // ── Envío local (sin API aún) ──────────────────────────────────────────────

  void _onTextMessageSent(
    ChatDetailTextMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;
    if (event.mensaje.trim().isEmpty) return;

    final currentMessages = (state as ChatDetailSuccess).messages;
    final newMessage = ChatMessage(
      idMensaje: const Uuid().v4(),
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: event.mensaje.trim(),
      tipo: 'text',
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: '',
      extArchivo: '',
      idChatCab: '',
      idChatDet: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );
  }

  void _onAudioMessageSent(
    ChatDetailAudioMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

    final currentMessages = (state as ChatDetailSuccess).messages;
    final newMessage = ChatMessage(
      idMensaje: const Uuid().v4(),
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: event.audioPath,
      tipo: 'audio',
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: 'audio_${DateTime.now().millisecondsSinceEpoch}',
      extArchivo: 'm4a',
      idChatCab: '',
      idChatDet: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );
  }

  void _onFileMessageSent(
    ChatDetailFileMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

    final currentMessages = (state as ChatDetailSuccess).messages;
    final newMessage = ChatMessage(
      idMensaje: const Uuid().v4(),
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: event.filePath,
      tipo: event.tipo,
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: event.fileName,
      extArchivo: event.fileExt,
      idChatCab: '',
      idChatDet: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );
  }
}
