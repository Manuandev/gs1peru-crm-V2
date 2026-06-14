// lib/features/chat/presentation/bloc/chat_detail/chat_detail_bloc.dart

import 'dart:async';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetChatMessagesUseCase _getChatMessages;
  final SendChatMessageUseCase _sendChatMessage;
  final SendFileMessageUseCase _sendFileMessage;
  final SendTemplateMessageUseCase _sendTemplateMessage;

  StreamSubscription<WebSocketMessage>? _messageSubscription;

  final _session = SessionService();

  int? _currentLeadId;

  ChatDetailBloc(
    this._getChatMessages,
    this._sendChatMessage,
    this._sendFileMessage,
    this._sendTemplateMessage,
  ) : super(const ChatDetailInitial()) {
    on<ChatDetailStarted>(_onStarted);
    on<ChatDetailRefreshed>(_onRefreshed);
    on<ChatDetailMoreMessagesLoaded>(_onMoreMessagesLoaded);
    on<ChatDetailTextMessageSent>(_onTextMessageSent);
    on<ChatDetailTemplateMessageSent>(_onTemplateMessageSent);
    on<ChatDetailAudioMessageSent>(_onAudioMessageSent);
    on<ChatDetailFileMessageSent>(_onFileMessageSent);
    on<ChatDetailBatchFileMessageSent>(_onBatchFileMessageSent);
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
    LocalNotificationService.instance.clearLead(event.idLead);
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

  Future<void> _loadMessages(int idLead, Emitter<ChatDetailState> emit) async {
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

  void _onTemplateMessageSent(
    ChatDetailTemplateMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

    final mensajeFormateado = event.template.detalle
        .replaceAll('{{nombre_cliente}}', event.nombreCliente)
        .replaceAll('{{apellido_cliente}}', event.apellidoCliente)
        .replaceAll('{{nombre_asesor}}', _session.userApe);

    final tempId = const Uuid().v4();
    final currentMessages = (state as ChatDetailSuccess).messages;

    final tieneArchivo = event.template.rutaArchivo.isNotEmpty;
    final tipo = tieneArchivo
        ? _tipoDeExtension(event.template.extensionArchivo)
        : 'text';

    final newMessage = ChatMessage(
      idMensaje: tempId,
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: tieneArchivo ? event.template.rutaArchivo : mensajeFormateado,
      tipo: tipo,
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: event.template.nombreArchivo,
      extArchivo: event.template.extensionArchivo,
      idChatCab: event.chatCab,
      idChatDet: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentLeadId != null) {
      _sendTemplateMessage(
        template: event.template,
        mensajeFormateado: mensajeFormateado,
        idLead: _currentLeadId.toString(),
        numero: event.numero,
        chatCab: event.chatCab,
        nombreCliente: event.nombreCliente,
        apellidoCliente: event.apellidoCliente,
        isExpirado: event.isExpirado,
        isCerrado: event.isCerrado,
      );
    }
  }

  /// Infiere el tipo de mensaje según la extensión del archivo de la plantilla
  static String _tipoDeExtension(String ext) {
    final e = ext.toLowerCase().replaceAll('.', '');
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(e)) return 'image';
    if (['mp4', 'mov', 'avi'].contains(e)) return 'video';
    if (['mp3', 'm4a', 'ogg', 'wav'].contains(e)) return 'audio';
    return 'document';
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
    // Nombre con ms para matching único
    final uniqueName =
        '${event.fileName}_${DateTime.now().millisecondsSinceEpoch}';

    final currentMessages = (state as ChatDetailSuccess).messages;
    final newMessage = ChatMessage(
      idMensaje: tempId,
      fecha: DateTime.now().toIso8601String(),
      isEnviado: true,
      mensaje: event.filePath,
      tipo: event.tipo,
      estado: 'wait',
      idChatDetArc: '',
      nomArchivo: uniqueName,
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
        fileName: '$uniqueName${event.fileExt}',
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

  // ── Envío batch (múltiples archivos en paralelo) ──────────────────────────

  Future<void> _onBatchFileMessageSent(
    ChatDetailBatchFileMessageSent event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailSuccess) return;

    // 1. Crear mensajes optimistas
    final tempIds = <String>[];
    final uniqueNames = <String>[];
    final currentMessages = List<ChatMessage>.from(
      (state as ChatDetailSuccess).messages,
    );

    for (final file in event.files) {
      final tempId = const Uuid().v4();
      final uniqueName =
          '${file.nameWithoutExt}_${DateTime.now().millisecondsSinceEpoch + tempIds.length}';

      tempIds.add(tempId);
      uniqueNames.add(uniqueName);

      currentMessages.add(
        ChatMessage(
          idMensaje: tempId,
          fecha: DateTime.now().toIso8601String(),
          isEnviado: true,
          mensaje: file.path,
          tipo: file.tipo,
          estado: 'wait',
          idChatDetArc: '',
          nomArchivo: uniqueName,
          extArchivo: file.ext,
          idChatCab: event.chatCab,
          idChatDet: '',
        ),
      );
    }

    emit((state as ChatDetailSuccess).copyWith(messages: currentMessages));

    // 2. Enviar todos en paralelo
    if (_currentLeadId == null) return;

    final futures = List.generate(event.files.length, (i) async {
      final file = event.files[i];
      final success = await _sendFileMessage(
        filePath: file.path,
        fileName: '${uniqueNames[i]}${file.ext}',
        tipo: file.tipo,
        idLead: _currentLeadId.toString(),
        numero: event.numero,
        chatCab: event.chatCab,
      );
      if (!success && !isClosed) {
        _markMessageAsFailed(tempIds[i], emit);
      }
    });

    await Future.wait(futures);
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
    if (state is! ChatDetailSuccess) return;
    final currentState = state as ChatDetailSuccess;
    final payload = UpdatePantallaWhatsAppPayload.fromMessage(message);
    if (payload == null) return;
    if (payload.leadId != _currentLeadId) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Evitar duplicados
    if (currentMessages.any((m) => m.idMensaje == payload.idMensaje)) return;

    final pendingIndex = _findPendingIndex(currentMessages, payload);

    if (pendingIndex != -1) {
      // Asignar idMensaje real — desde aquí UPDATE_MENSAJE lo encuentra por id directo
      final pName = _removeExt(payload.nomArchivo);
      final pExt = _extractExt(payload.nomArchivo);

      currentMessages[pendingIndex] = currentMessages[pendingIndex].copyWith(
        idMensaje: payload.idMensaje,
        estado: 'sent',
        idChatCab: payload.idChatCab,
        nomArchivo: pName.isNotEmpty
            ? pName
            : currentMessages[pendingIndex].nomArchivo,
        extArchivo: pExt.isNotEmpty
            ? pExt
            : currentMessages[pendingIndex].extArchivo,
      );
    } else {
      // Enviado desde otra sesión
      final pName = _removeExt(payload.nomArchivo);
      final pExt = _extractExt(payload.nomArchivo);

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
          nomArchivo: pName,
          extArchivo: pExt,
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

  int _findPendingIndex(
    List<ChatMessage> messages,
    UpdatePantallaWhatsAppPayload payload,
  ) {
    // Regex UUID v4
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
      caseSensitive: false,
    );

    return messages.lastIndexWhere((m) {
      // Solo mensajes optimistas pendientes
      if (m.estado != 'wait' || m.isEnviado != true) return false;
      // Solo los que aún tienen tempId (UUID) — no los ya confirmados
      if (!uuidRegex.hasMatch(m.idMensaje)) return false;
      // Mismo tipo — las plantillas se guardan localmente como 'text' o tipo de
      // archivo, pero el servidor responde con 'template'; no filtrar por tipo en ese caso
      if (payload.tipoMensaje.isNotEmpty &&
          m.tipo != payload.tipoMensaje &&
          payload.tipoMensaje != 'template') {
        return false;
      }

      switch (payload.tipoMensaje) {
        case 'text':
          return m.mensaje == payload.mensaje;

        case 'template':
          if (payload.nomArchivo.isEmpty) {
            return m.mensaje == payload.mensaje;
          }
          return m.nomArchivo == _removeExt(payload.nomArchivo) &&
              m.extArchivo == _extractExt(payload.nomArchivo);

        case 'image':
        case 'video':
        case 'audio':
        case 'document':
          if (payload.nomArchivo.isEmpty) return false;

          return m.nomArchivo == _removeExt(payload.nomArchivo) &&
              m.extArchivo == _extractExt(payload.nomArchivo);

        default:
          return m.mensaje == payload.mensaje;
      }
    });
  }
}
