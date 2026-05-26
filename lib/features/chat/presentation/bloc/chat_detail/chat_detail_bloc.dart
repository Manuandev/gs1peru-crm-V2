// lib\features\chat\presentation\bloc\chat_detail\chat_detail_bloc.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ignore: depend_on_referenced_packages
import 'package:uuid/uuid.dart';
 import 'dart:async';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetChatMessagesUseCase _getChatMessages;
  final SendChatMessageUseCase _sendChatMessage;
  StreamSubscription<WebSocketMessage>? _messageSubscription;
  int? _currentLeadId;

  ChatDetailBloc(
    this._getChatMessages,
    this._sendChatMessage,
  ) : super(const ChatDetailInitial()) {
    on<ChatDetailStarted>(_onStarted);
    on<ChatDetailRefreshed>(_onRefreshed);
    on<ChatDetailMoreMessagesLoaded>(_onMoreMessagesLoaded);
    on<ChatDetailTextMessageSent>(_onTextMessageSent);
    on<ChatDetailAudioMessageSent>(_onAudioMessageSent);
    on<ChatDetailFileMessageSent>(_onFileMessageSent);
    on<ChatDetailIncomingMessageReceived>(_onIncomingMessageReceived);

    _messageSubscription = MessageDispatcher.instance.stream.listen((message) {
      if (!isClosed) {
        add(ChatDetailIncomingMessageReceived(message));
      }
    });
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }

  // ── Carga inicial ──────────────────────────────────────────────────────────

  Future<void> _onStarted(
    ChatDetailStarted event,
    Emitter<ChatDetailState> emit,
  ) async {
    _currentLeadId = event.idLead;
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
    int idLead,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      final messages = await _getChatMessages(idLead);

      final sorted = [...messages]
        ..sort((a, b) {
          final fechaA = DateFormatter.parseDate(a.fecha) ?? DateTime(0);
          final fechaB = DateFormatter.parseDate(b.fecha) ?? DateTime(0);
          final cmp = fechaA.compareTo(fechaB);
          if (cmp != 0) return cmp;
          // 👇 mismo minuto → ordena por idChatDet
          return (int.tryParse(a.idChatDet) ?? 0).compareTo(
            int.tryParse(b.idChatDet) ?? 0,
          );
        });

      emit(ChatDetailSuccess(messages: sorted, hasMore: messages.isNotEmpty));
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
    if (!currentState.hasMore) return;

    emit(ChatDetailLoadingMore(messages: currentState.messages));

    try {
      final newMessages = await _getChatMessages(
        event.idLead,
        idUltimoMensaje: event.idUltimoMensaje,
      );

      final merged = [...newMessages, ...currentState.messages];

      final seen = <String>{};
      final unique = merged.where((m) => seen.add(m.idMensaje)).toList();
      unique.sort((a, b) {
        final fechaA = DateFormatter.parseDate(a.fecha) ?? DateTime(0);
        final fechaB = DateFormatter.parseDate(b.fecha) ?? DateTime(0);
        final cmp = fechaA.compareTo(fechaB);
        if (cmp != 0) return cmp;
        // 👇 mismo minuto → ordena por idChatDet
        return (int.tryParse(a.idChatDet) ?? 0).compareTo(
          int.tryParse(b.idChatDet) ?? 0,
        );
      });

      emit(
        ChatDetailSuccess(
          messages: unique,
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

    final tempId = const Uuid().v4();

    final currentMessages = (state as ChatDetailSuccess).messages;
    final newMessage = ChatMessage(
      idMensaje: tempId,
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: event.mensaje.trim(),
      tipo: 'text',
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: '',
      extArchivo: '',
      idChatCab: event.chatCab,
      idChatDet: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentLeadId != null) {
      _sendChatMessage(
        event.mensaje.trim(),
        _currentLeadId.toString(),
        event.numero,
        event.chatCab,
      );
    }
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

  void _onIncomingMessageReceived(
    ChatDetailIncomingMessageReceived event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;
    final currentState = state as ChatDetailSuccess;

    if (event.message.process != 'MENSAJE_WHATSAPP') return;

    final payload = WhatsAppMessagePayload.fromMessage(event.message);
    if (payload == null) return;

    // Solo procesamos si pertenece a este lead
    if (payload.leadId != _currentLeadId) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Buscar si tenemos un mensaje pendiente (estado 'wait') con el mismo contenido
    // asumiendo que el server broadcast envía de vuelta el mensaje de nuestro usuario (isEnviado = true)
    final pendingIndex = currentMessages.lastIndexWhere(
      (m) => m.estado == 'wait' && m.mensaje == payload.mensaje && m.isEnviado == true,
    );

    final incomingMessage = ChatMessage(
      idMensaje: payload.whatsappMsgId.isNotEmpty ? payload.whatsappMsgId : payload.idInterno.toString(),
      fecha: payload.fecha.isNotEmpty ? payload.fecha : DateTime.now().toIso8601String(),
      isEnviado: true, // Si es el nuestro, isEnviado es true, si es del cliente, false. 
      // NOTA: Para diferenciar envíado/recibido normalmente validas contra un ID de asesor o algo,
      // pero provisionalmente lo dejamos como isEnviado = pendingIndex != -1, o mejor aún,
      // la API nos mandará un flag. Asumiremos que si estaba en wait, es nuestro.
      mensaje: payload.mensaje,
      tipo: payload.tipoMensaje.isNotEmpty ? payload.tipoMensaje : 'text',
      estado: 'sent', // O el estado real
      idChatDetArc: '',
      nomArchivo: payload.nomArchivo,
      extArchivo: '',
      idChatCab: '',
      idChatDet: payload.idInterno.toString(),
    );

    if (pendingIndex != -1) {
      // Reemplazar optimista
      currentMessages[pendingIndex] = incomingMessage.copyWith(isEnviado: true);
    } else {
      // Nuevo mensaje entrante
      // Asumiremos isEnviado = false (es decir, del cliente) a menos que la trama nos indique otra cosa
      currentMessages.add(incomingMessage.copyWith(isEnviado: false));
    }

    emit(currentState.copyWith(messages: currentMessages));
  }
}
