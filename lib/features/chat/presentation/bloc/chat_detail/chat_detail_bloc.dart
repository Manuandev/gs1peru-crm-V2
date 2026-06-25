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

  int? _currentIdNumero;

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
    _currentIdNumero = event.idNumero;
    LocalNotificationService.instance.clearLead(event.idNumero);
    emit(const ChatDetailLoading());
    await _loadMessages(event.idNumero, emit);
  }

  Future<void> _onRefreshed(
    ChatDetailRefreshed event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(const ChatDetailLoading());
    await _loadMessages(event.idNumero, emit);
  }

  Future<void> _loadMessages(int idLead, Emitter<ChatDetailState> emit) async {
    try {
      final messages = await _getChatMessages(idLead);

      final sorted = [...messages]
        ..sort((a, b) {
          final fechaA = DateFormatter.parseDate(a.fechaHora) ?? DateTime(0);
          final fechaB = DateFormatter.parseDate(b.fechaHora) ?? DateTime(0);
          final cmp = fechaA.compareTo(fechaB);
          if (cmp != 0) return cmp;
          // 👇 mismo minuto → ordena por idChatDet
          return (a.idConversacionDet).compareTo(b.idConversacionDet);
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
        event.idNumero,
        idUltimoMensaje: event.idUltimoMensaje,
      );

      final merged = [...newMessages, ...currentState.messages];

      final seen = <String>{};
      final unique = merged.where((m) {
        // Clave de deduplicación: UUID si está disponible, si no usar idConversacionDet + contenido
        final key = m.idTokenMeta.isNotEmpty
            ? m.idTokenMeta
            : 'fallback:${m.idConversacionDet}|${m.fechaHora}|${m.contenido.hashCode}';
        return seen.add(key);
      }).toList();
      unique.sort((a, b) {
        final fechaA = DateFormatter.parseDate(a.fechaHora) ?? DateTime(0);
        final fechaB = DateFormatter.parseDate(b.fechaHora) ?? DateTime(0);
        final cmp = fechaA.compareTo(fechaB);
        if (cmp != 0) return cmp;
        // 👇 mismo minuto → ordena por idChatDet
        return (a.idConversacionDet).compareTo(b.idConversacionDet);
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
      idConversacionCab: int.tryParse(event.chatCab) ?? 0,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: event.mensaje.trim(),
      tipo: 'text',
      estadoEntrega: 'wait',
      rutaArchivo: '',
      tipoArchivo: 'text',
      nombreArchivo: '',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentIdNumero != null) {
      _sendChatMessage(
        event.mensaje.trim(),
        _currentIdNumero.toString(),
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
      idConversacionCab: int.tryParse(event.chatCab) ?? 0,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: tieneArchivo ? event.template.rutaArchivo : mensajeFormateado,
      tipo: tipo,
      estadoEntrega: 'wait',
      rutaArchivo: '',
      tipoArchivo: tipo,
      nombreArchivo: event.template.nombreArchivo,
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentIdNumero != null) {
      _sendTemplateMessage(
        template: event.template,
        mensajeFormateado: mensajeFormateado,
        idNumero: _currentIdNumero.toString(),
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
      idConversacionCab: int.tryParse(event.chatCab) ?? 0,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: event.audioPath,
      tipo: 'audio',
      estadoEntrega: 'wait',
      rutaArchivo: '',
      tipoArchivo: 'audio',
      nombreArchivo: fileName,
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentIdNumero != null) {
      final success = await _sendFileMessage(
        filePath: event.audioPath,
        fileName: fileName,
        tipo: 'audio',
        idNumero: _currentIdNumero.toString(),
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
      idConversacionCab: int.tryParse(event.chatCab) ?? 0,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: event.filePath,
      tipo: event.tipo,
      estadoEntrega: 'wait',
      rutaArchivo: '',
      tipoArchivo: event.tipo,
      nombreArchivo: '$uniqueName${event.fileExt}',
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentIdNumero != null) {
      final success = await _sendFileMessage(
        filePath: event.filePath,
        fileName: '$uniqueName${event.fileExt}',
        tipo: event.tipo,
        idNumero: _currentIdNumero.toString(),
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
          idConversacionCab: int.tryParse(event.chatCab) ?? 0,
          idConversacionDet: 0,
          idTokenMeta: tempId,
          fechaHora: DateTime.now().toIso8601String(),
          direccionMensaje: 'ASE',
          contenido: file.path,
          tipo: file.tipo,
          estadoEntrega: 'wait',
          rutaArchivo: '',
          tipoArchivo: file.tipo,
          nombreArchivo: '$uniqueName${file.ext}',
        ),
      );
    }

    emit((state as ChatDetailSuccess).copyWith(messages: currentMessages));

    // 2. Enviar todos en paralelo
    if (_currentIdNumero == null) return;

    final futures = List.generate(event.files.length, (i) async {
      final file = event.files[i];
      final success = await _sendFileMessage(
        filePath: file.path,
        fileName: '${uniqueNames[i]}${file.ext}',
        tipo: file.tipo,
        idNumero: _currentIdNumero.toString(),
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
    final idx = messages.indexWhere((m) => m.idTokenMeta == tempId);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(estadoEntrega: 'failed');
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
    if (payload.idNumero != _currentIdNumero) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Verificar si ya existe un mensaje con este idMensaje (evitar duplicados)
    final exists = currentMessages.any(
      (m) => m.idTokenMeta == payload.idTokenMeta,
    );
    if (exists) return;

    // Extraer extensión del nombre de archivo (e.g. 'doc.xlsx' → '.xlsx')
    // final extFromName = _extractExt(payload.nomArchivo);
    // final nameWithoutExt = _removeExt(payload.nomArchivo);

    // nomArchivo llega con extensión incluida ("foto.jpeg") — separar como hace BD
    final pName = _removeExt(payload.nomArchivo);
    final pExt = _extractExt(payload.nomArchivo);

    // MENSAJE_WHATSAPP siempre es un mensaje del cliente → isEnviado = false
    final incomingMessage = ChatMessage(
      idConversacionCab: int.tryParse(payload.idChatCab) ?? 0,
      idConversacionDet: 0,
      idTokenMeta: payload.idTokenMeta,
      fechaHora: payload.fecha.isNotEmpty
          ? payload.fecha
          : DateTime.now().toIso8601String(),
      direccionMensaje: 'CLI',
      contenido: payload.mensaje,
      tipo: payload.tipoMensaje.isNotEmpty ? payload.tipoMensaje : 'text',
      estadoEntrega: '',
      rutaArchivo: '',
      tipoArchivo: pExt,
      nombreArchivo: pName,
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
    if (payload.idNumero != _currentIdNumero) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Evitar duplicados
    if (currentMessages.any((m) => m.idTokenMeta == payload.idTokenMeta)) {
      return;
    }

    final pendingIndex = _findPendingIndex(currentMessages, payload);

    if (pendingIndex != -1) {
      // Asignar idTokenMeta real — desde aquí UPDATE_MENSAJE lo encuentra por id directo
      final pName = _removeExt(payload.nomArchivo);
      final pExt = _extractExt(payload.nomArchivo);

      currentMessages[pendingIndex] = currentMessages[pendingIndex].copyWith(
        idTokenMeta: payload.idTokenMeta,
        estadoEntrega: 'sent',
        idConversacionCab: int.tryParse(payload.idChatCab) ?? 0,
        nombreArchivo: pName.isNotEmpty
            ? pName
            : currentMessages[pendingIndex].nombreArchivo,
        tipoArchivo: pExt.isNotEmpty
            ? pExt
            : currentMessages[pendingIndex].tipoArchivo,
      );
    } else {
      // Enviado desde otra sesión
      final pName = _removeExt(payload.nomArchivo);
      final pExt = _extractExt(payload.nomArchivo);

      currentMessages.add(
        ChatMessage(
          idTokenMeta: payload.idTokenMeta,
          fechaHora: payload.hora.isNotEmpty
              ? payload.hora
              : DateTime.now().toIso8601String(),
          direccionMensaje: 'ASE',
          contenido: payload.mensaje,
          tipo: payload.tipoMensaje.isNotEmpty ? payload.tipoMensaje : 'text',
          estadoEntrega: 'sent',
          rutaArchivo: '',
          nombreArchivo: pName,
          tipoArchivo: pExt,
          idConversacionCab: int.tryParse(payload.idChatCab) ?? 0,
          idConversacionDet: 0,
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
    if (payload.idNumero != _currentIdNumero) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // Buscar el mensaje por su idMensaje
    final msgIndex = currentMessages.indexWhere(
      (m) => m.idTokenMeta == payload.idMensaje,
    );

    if (msgIndex == -1) return; // Mensaje no encontrado, ignorar

    // Actualizar solo el estado del mensaje
    currentMessages[msgIndex] = currentMessages[msgIndex].copyWith(
      estadoEntrega: payload.estado,
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
      // Solo mensajes optimistas pendientes enviados por el asesor o IA
      if (m.estadoEntrega != 'wait') return false;
      if (m.direccionMensaje != 'ASE' && m.direccionMensaje != 'AIA') return false;
      // Solo los que aún tienen tempId (UUID) — no los ya confirmados
      if (!uuidRegex.hasMatch(m.idTokenMeta)) return false;
      // Mismo tipo — las plantillas se guardan localmente como 'text' o tipo de
      // archivo, pero el servidor responde con 'template'; no filtrar por tipo en ese caso
      if (payload.tipoMensaje.isNotEmpty &&
          m.tipo != payload.tipoMensaje &&
          payload.tipoMensaje != 'template') {
        return false;
      }

      switch (payload.tipoMensaje) {
        case 'text':
          return m.contenido == payload.mensaje;

        case 'template':
          if (payload.nomArchivo.isEmpty) {
            return m.contenido == payload.mensaje;
          }
          return m.nombreArchivo == _removeExt(payload.nomArchivo) &&
              m.tipoArchivo == _extractExt(payload.nomArchivo);

        case 'image':
        case 'video':
        case 'audio':
        case 'document':
          if (payload.nomArchivo.isEmpty) return false;

          return m.nombreArchivo == _removeExt(payload.nomArchivo) &&
              m.tipoArchivo == _extractExt(payload.nomArchivo);

        default:
          return m.contenido == payload.mensaje;
      }
    });
  }
}
