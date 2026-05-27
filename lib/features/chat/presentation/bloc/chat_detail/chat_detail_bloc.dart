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


  final SendFileMessageUseCase _sendFileMessage;

  ChatDetailBloc(
    this._getChatMessages,
    this._sendChatMessage,
    this._sendFileMessage,
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

  // ── Envío local ──────────────────────────────────────────────

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

  Future<void> _onAudioMessageSent(
    ChatDetailAudioMessageSent event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailSuccess) return;

    final tempId = const Uuid().v4();
    final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

    final currentMessages = (state as ChatDetailSuccess).messages;
    final newMessage = ChatMessage(
      idMensaje: tempId,
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: event.audioPath,
      tipo: 'audio',
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: fileName,
      extArchivo: 'm4a',
      idChatCab: event.chatCab,
      idChatDet: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentLeadId != null) {
      final success = await _sendFileMessage(
        filePath: event.audioPath,
        fileName: fileName,
        tipo: 'audio',
        idLead: _currentLeadId.toString(),
        numero: event.numero,
        chatCab: event.chatCab,
      );

      if (!success && !isClosed) {
        // Actualizar UI: mensaje fallido
        _markMessageAsFailed(tempId, emit);
      }
    }
  }

  Future<void> _onFileMessageSent(
    ChatDetailFileMessageSent event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailSuccess) return;

    final tempId = const Uuid().v4();

    final currentMessages = (state as ChatDetailSuccess).messages;
    final newMessage = ChatMessage(
      idMensaje: tempId,
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: event.filePath,
      tipo: event.tipo,
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: event.fileName,
      extArchivo: event.fileExt,
      idChatCab: event.chatCab,
      idChatDet: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentLeadId != null) {
      final success = await _sendFileMessage(
        filePath: event.filePath,
        fileName: event.fileName,
        tipo: event.tipo,
        idLead: _currentLeadId.toString(),
        numero: event.numero,
        chatCab: event.chatCab,
      );

      if (!success && !isClosed) {
        // Actualizar UI: mensaje fallido
        _markMessageAsFailed(tempId, emit);
      }
    }
  }

  void _markMessageAsFailed(String tempId, Emitter<ChatDetailState> emit) {
    if (state is! ChatDetailSuccess) return;
    final currentState = state as ChatDetailSuccess;
    final messages = List<ChatMessage>.from(currentState.messages);
    final idx = messages.indexWhere((m) => m.idMensaje == tempId);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(estado: 'failed');
      emit(currentState.copyWith(messages: messages));
    }
  }

  // ── Router de mensajes entrantes ───────────────────────────────────────────

  void _onIncomingMessageReceived(
    ChatDetailIncomingMessageReceived event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

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
    Emitter<ChatDetailState> emit,
  ) {
    final currentState = state as ChatDetailSuccess;
    final payload = WhatsAppMessagePayload.fromMessage(message);
    if (payload == null) return;

    // Solo procesamos si pertenece a este lead
    if (payload.leadId != _currentLeadId) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Verificar si ya existe un mensaje con este idMensaje (evitar duplicados)
    final exists = currentMessages.any((m) => m.idMensaje == payload.idMensaje);
    if (exists) return;

    // Extraer extensión del nombre de archivo (e.g. 'doc.xlsx' → '.xlsx')
    final extFromName = _extractExt(payload.nomArchivo);
    final nameWithoutExt = _removeExt(payload.nomArchivo);

    // MENSAJE_WHATSAPP siempre es un mensaje del cliente → isEnviado = false
    final incomingMessage = ChatMessage(
      idMensaje: payload.idMensaje,
      fecha: payload.fecha.isNotEmpty
          ? payload.fecha
          : DateTime.now().toIso8601String(),
      isEnviado: false, // Siempre false — el cliente envió este mensaje
      mensaje: payload.mensaje,
      tipo: payload.tipoMensaje.isNotEmpty ? payload.tipoMensaje : 'text',
      estado: '', // Mensajes recibidos no tienen estado de checks
      idChatDetArc: '',
      nomArchivo: nameWithoutExt,
      extArchivo: extFromName,
      idChatCab: payload.idChatCab,
      idChatDet: '',
    );

    currentMessages.add(incomingMessage);
    emit(currentState.copyWith(messages: currentMessages));
  }

  // ── UPDATE_PANTALLA_WHATSAPP — Confirmación de nuestro mensaje enviado ─────

  void _handleUpdatePantalla(
    WebSocketMessage message,
    Emitter<ChatDetailState> emit,
  ) {
    final currentState = state as ChatDetailSuccess;
    final payload = UpdatePantallaWhatsAppPayload.fromMessage(message);
    if (payload == null) return;

    // Solo procesamos si pertenece a este lead
    if (payload.leadId != _currentLeadId) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Buscar el mensaje pendiente (estado 'wait') que coincida con el contenido
    // y sea nuestro (isEnviado = true)
    final pendingIndex = currentMessages.lastIndexWhere(
      (m) =>
          m.estado == 'wait' &&
          m.isEnviado == true &&
          m.mensaje == payload.mensaje,
    );

    if (pendingIndex != -1) {
      // Reemplazar el mensaje optimista con los datos reales del servidor
      currentMessages[pendingIndex] = currentMessages[pendingIndex].copyWith(
        idMensaje: payload.idMensaje,
        estado: 'sent',
        idChatCab: payload.idChatCab,
      );
    } else {
      // No encontramos un pendiente — agregar como mensaje nuevo enviado
      // (posiblemente enviado desde otra sesión / otro dispositivo)
      final exists = currentMessages.any(
        (m) => m.idMensaje == payload.idMensaje,
      );
      if (exists) return;

      final extFromName2 = _extractExt(payload.nomArchivo);
      final nameWithoutExt2 = _removeExt(payload.nomArchivo);

      currentMessages.add(
        ChatMessage(
          idMensaje: payload.idMensaje,
          fecha: payload.hora.isNotEmpty
              ? payload.hora
              : DateTime.now().toIso8601String(),
          isEnviado: true,
          mensaje: payload.mensaje,
          tipo: payload.tipoMensaje.isNotEmpty ? payload.tipoMensaje : 'text',
          estado: 'sent',
          idChatDetArc: '',
          nomArchivo: nameWithoutExt2,
          extArchivo: extFromName2,
          idChatCab: payload.idChatCab,
          idChatDet: '',
        ),
      );
    }

    emit(currentState.copyWith(messages: currentMessages));
  }

  // ── UPDATE_MENSAJE_WHATSAPP — Cambio de estado (sent → delivered → read) ──

  void _handleUpdateMensaje(
    WebSocketMessage message,
    Emitter<ChatDetailState> emit,
  ) {
    final currentState = state as ChatDetailSuccess;
    final payload = UpdateMensajeWhatsAppPayload.fromMessage(message);
    if (payload == null) return;

    // Solo procesamos si pertenece a este lead
    if (payload.leadId != _currentLeadId) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Buscar el mensaje por su idMensaje
    final msgIndex = currentMessages.indexWhere(
      (m) => m.idMensaje == payload.idMensaje,
    );

    if (msgIndex == -1) return; // Mensaje no encontrado, ignorar

    // Actualizar solo el estado del mensaje
    currentMessages[msgIndex] = currentMessages[msgIndex].copyWith(
      estado: payload.estado,
    );

    emit(currentState.copyWith(messages: currentMessages));
  }

  // ── Helpers para extraer extensión del nombre de archivo ───────────────────

  /// 'reporte.xlsx' → '.xlsx', '' → ''
  static String _extractExt(String fileName) {
    if (fileName.isEmpty) return '';
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(dotIndex) : '';
  }

  /// 'reporte.xlsx' → 'reporte', '' → ''
  static String _removeExt(String fileName) {
    if (fileName.isEmpty) return '';
    final dotIndex = fileName.lastIndexOf('.');
    return dotIndex != -1 ? fileName.substring(0, dotIndex) : fileName;
  }
}
