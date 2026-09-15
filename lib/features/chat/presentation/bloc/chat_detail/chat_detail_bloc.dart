// lib/features/chat/presentation/bloc/chat_detail/chat_detail_bloc.dart

import 'dart:async';
import 'dart:io';
import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

/// Un envío retenido durante la ventana de "Deshacer": el mensaje ya se ve en
/// pantalla, pero [enviar] (socket / subida de archivo) recién corre cuando
/// vence [timer]. Devuelve `false` si el envío falló (para marcarlo 'failed').
class _EnvioProgramado {
  final ChatMessage mensaje;
  final Timer timer;
  final Future<bool> Function() enviar;

  const _EnvioProgramado({
    required this.mensaje,
    required this.timer,
    required this.enviar,
  });
}

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final GetChatMessagesUseCase _getChatMessages;
  final SendChatMessageUseCase _sendChatMessage;
  final SendFileMessageUseCase _sendFileMessage;
  final SendTemplateMessageUseCase _sendTemplateMessage;

  StreamSubscription<WebSocketMessage>? _messageSubscription;

  final _session = SessionService();

  int? _currentChatCab;

  // Envíos en ventana de "Deshacer", por tempId (idTokenMeta optimista).
  // Las plantillas NO pasan por acá — se envían directo, como siempre.
  final Map<String, _EnvioProgramado> _enviosProgramados = {};

  // Texto de un mensaje deshecho — ChatInputBar lo devuelve a la caja de
  // escribir para que el asesor lo corrija.
  final _textosRestaurados = StreamController<String>.broadcast();
  Stream<String> get textosRestaurados => _textosRestaurados.stream;

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
    on<ChatDetailEnvioDeshecho>(_onEnvioDeshecho);
    on<ChatDetailEnvioConfirmado>(_onEnvioConfirmado);
    on<ChatDetailIncomingMessageReceived>(_onIncomingMessageReceived);

    _messageSubscription = MessageDispatcher.instance.stream.listen((message) {
      if (!isClosed) {
        add(ChatDetailIncomingMessageReceived(message));
      }
    });
  }

  @override
  Future<void> close() async {
    _messageSubscription?.cancel();
    // Salir del chat con mensajes aún en la ventana de "Deshacer" → se envían
    // ya mismo, para que nunca se pierda un mensaje sin que el asesor lo note.
    for (final envio in _enviosProgramados.values) {
      envio.timer.cancel();
      unawaited(envio.enviar());
    }
    _enviosProgramados.clear();
    await _textosRestaurados.close();
    return super.close();
  }

  // ── Carga inicial ──────────────────────────────────────────────────────────

  Future<void> _onStarted(
    ChatDetailStarted event,
    Emitter<ChatDetailState> emit,
  ) async {
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

  Future<void> _loadMessages(int idNumero, Emitter<ChatDetailState> emit) async {
    try {
      final messages = await _getChatMessages(idNumero);

      final sorted = [...messages]
        ..sort((a, b) {
          final fechaA = DateFormatter.parseDate(a.fechaHora) ?? DateTime(0);
          final fechaB = DateFormatter.parseDate(b.fechaHora) ?? DateTime(0);
          final cmp = fechaA.compareTo(fechaB);
          if (cmp != 0) return cmp;
          // 👇 mismo minuto → ordena por idChatDet
          return (a.idConversacionDet).compareTo(b.idConversacionDet);
        });

      if (sorted.isNotEmpty) {
        _currentChatCab = sorted.last.idConversacionCab;
      }
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
    final texto = event.mensaje.trim();
    final chatCab = _currentChatCab;

    final newMessage = ChatMessage(
      idConversacionCab: event.idChatCab,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: texto,
      tipo: 'text',
      estadoEntrega: ChatMessage.estadoProgramado,
      rutaArchivo: '',
      tipoArchivo: 'text',
      nombreArchivo: '',
    );

    _agregarMensajes([newMessage], emit);

    _programarEnvio(newMessage, () async {
      if (chatCab != null) {
        _sendChatMessage(
          texto,
          chatCab.toString(),
          event.numero,
          event.idChatCab,
        );
      }
      return true;
    });
  }

  // Plantillas: sin ventana de "Deshacer" — se envían al toque, como siempre.
  void _onTemplateMessageSent(
    ChatDetailTemplateMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

    final mensajeFormateado = event.template.contenido
        .replaceAll('{{nombre_cliente}}', event.nombreCliente)
        .replaceAll('{{apellido_cliente}}', event.apellidoCliente)
        .replaceAll('{{nombre_asesor}}', _session.userApe);

    final tempId = const Uuid().v4();
    final currentMessages = (state as ChatDetailSuccess).messages;

    final newMessage = ChatMessage(
      idConversacionCab: event.idChatCab,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: mensajeFormateado,
      tipo: 'template',
      estadoEntrega: 'wait',
      rutaArchivo: '',
      tipoArchivo: event.template.archivoExt,
      nombreArchivo: event.template.archivoNombre,
    );

    emit(
      (state as ChatDetailSuccess).copyWith(
        messages: [...currentMessages, newMessage],
      ),
    );

    if (_currentChatCab != null) {
      _sendTemplateMessage(
        plantilla: event.template,
        mensajeFormateado: mensajeFormateado,
        idNumero: _currentChatCab.toString(),
        numero: event.numero,
        chatCab: event.idChatCab,
        nombreCliente: event.nombreCliente,
        apellidoCliente: event.apellidoCliente,
        isExpirado: event.isExpirado,
        isCerrado: event.isCerrado,
      );
    }
  }

  void _onAudioMessageSent(
    ChatDetailAudioMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

    final tempId = const Uuid().v4();
    final nameWithoutExt = 'audio_${DateTime.now().millisecondsSinceEpoch}';
    const audioExt = '.m4a';
    final fileName = '$nameWithoutExt$audioExt';
    final chatCab = _currentChatCab;

    final newMessage = ChatMessage(
      idConversacionCab: event.idChatCab,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: event.audioPath,
      tipo: 'audio',
      estadoEntrega: ChatMessage.estadoProgramado,
      rutaArchivo: '',
      tipoArchivo: audioExt,
      nombreArchivo: nameWithoutExt,
    );

    _agregarMensajes([newMessage], emit);

    _programarEnvio(newMessage, () async {
      if (chatCab == null) return true;
      return _sendFileMessage(
        filePath: event.audioPath,
        fileName: fileName,
        tipo: 'audio',
        idNumero: chatCab.toString(),
        numero: event.numero,
        chatCab: event.idChatCab,
      );
    });
  }

  void _onFileMessageSent(
    ChatDetailFileMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

    final tempId = const Uuid().v4();
    final chatCab = _currentChatCab;

    final newMessage = ChatMessage(
      idConversacionCab: event.idChatCab,
      idConversacionDet: 0,
      idTokenMeta: tempId,
      fechaHora: DateTime.now().toIso8601String(),
      direccionMensaje: 'ASE',
      contenido: event.filePath,
      tipo: event.tipo,
      estadoEntrega: ChatMessage.estadoProgramado,
      rutaArchivo: '',
      tipoArchivo: event.fileExt,
      nombreArchivo: event.fileName,
    );

    _agregarMensajes([newMessage], emit);

    _programarEnvio(newMessage, () async {
      if (chatCab == null) return true;
      return _sendFileMessage(
        filePath: event.filePath,
        fileName: '${event.fileName}${event.fileExt}',
        tipo: event.tipo,
        idNumero: chatCab.toString(),
        numero: event.numero,
        chatCab: event.idChatCab,
      );
    });
  }

  // ── Envío batch (múltiples archivos) ──────────────────────────────────────
  // Cada archivo es un mensaje con su propio "Deshacer"; al vencer, los que
  // no se deshicieron salen en paralelo (cada timer dispara su propio evento).

  void _onBatchFileMessageSent(
    ChatDetailBatchFileMessageSent event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;

    final chatCab = _currentChatCab;
    final nuevos = <ChatMessage>[];

    for (final file in event.files) {
      nuevos.add(
        ChatMessage(
          idConversacionCab: event.idChatCab,
          idConversacionDet: 0,
          idTokenMeta: const Uuid().v4(),
          fechaHora: DateTime.now().toIso8601String(),
          direccionMensaje: 'ASE',
          contenido: file.path,
          tipo: file.tipo,
          estadoEntrega: ChatMessage.estadoProgramado,
          rutaArchivo: '',
          tipoArchivo: file.ext,
          nombreArchivo: file.nameWithoutExt,
        ),
      );
    }

    _agregarMensajes(nuevos, emit);

    for (var i = 0; i < event.files.length; i++) {
      final file = event.files[i];
      _programarEnvio(nuevos[i], () async {
        if (chatCab == null) return true;
        return _sendFileMessage(
          filePath: file.path,
          fileName: '${file.nameWithoutExt}${file.ext}',
          tipo: file.tipo,
          idNumero: chatCab.toString(),
          numero: event.numero,
          chatCab: event.idChatCab,
        );
      });
    }
  }

  // ── Ventana de "Deshacer" ──────────────────────────────────────────────────

  void _agregarMensajes(List<ChatMessage> nuevos, Emitter<ChatDetailState> emit) {
    final currentState = state as ChatDetailSuccess;
    emit(currentState.copyWith(messages: [...currentState.messages, ...nuevos]));
  }

  void _programarEnvio(ChatMessage mensaje, Future<bool> Function() enviar) {
    final tempId = mensaje.idTokenMeta;
    final segundos = ConfiguracionService().segundosDeshacerMensaje;
    _enviosProgramados[tempId] = _EnvioProgramado(
      mensaje: mensaje,
      enviar: enviar,
      timer: Timer(Duration(seconds: segundos), () {
        if (!isClosed) add(ChatDetailEnvioConfirmado(tempId));
      }),
    );
  }

  Future<void> _onEnvioConfirmado(
    ChatDetailEnvioConfirmado event,
    Emitter<ChatDetailState> emit,
  ) async {
    // Si ya no está, se deshizo justo antes de vencer — no se envía
    final envio = _enviosProgramados.remove(event.tempId);
    if (envio == null) return;

    // Desde acá ya no hay vuelta atrás: pasa a 'wait' como cualquier envío
    _actualizarEstadoMensaje(event.tempId, 'wait', emit);

    final exito = await envio.enviar();
    if (!exito && !isClosed) {
      _markMessageAsFailed(event.tempId, emit);
    }
  }

  void _onEnvioDeshecho(
    ChatDetailEnvioDeshecho event,
    Emitter<ChatDetailState> emit,
  ) {
    // null = ya venció y se envió — no hay nada que deshacer
    final envio = _enviosProgramados.remove(event.tempId);
    if (envio == null) return;
    envio.timer.cancel();

    if (state is ChatDetailSuccess) {
      final currentState = state as ChatDetailSuccess;
      emit(
        currentState.copyWith(
          messages: currentState.messages
              .where((m) => m.idTokenMeta != event.tempId)
              .toList(),
        ),
      );
    }

    final mensaje = envio.mensaje;
    if (mensaje.tipo == 'text') {
      _textosRestaurados.add(mensaje.contenido);
    } else if (mensaje.tipo == 'audio') {
      // El audio grabado vive en la carpeta temporal — si no se envía, se borra.
      // Imágenes/documentos NO: son copias que el picker ya maneja.
      _borrarArchivo(mensaje.contenido);
    }
  }

  void _actualizarEstadoMensaje(
    String tempId,
    String estado,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;
    final currentState = state as ChatDetailSuccess;
    final messages = List<ChatMessage>.from(currentState.messages);
    final idx = messages.indexWhere((m) => m.idTokenMeta == tempId);
    if (idx != -1) {
      messages[idx] = messages[idx].copyWith(estadoEntrega: estado);
      emit(currentState.copyWith(messages: messages));
    }
  }

  static Future<void> _borrarArchivo(String path) async {
    try {
      final archivo = File(path);
      if (await archivo.exists()) await archivo.delete();
    } catch (_) {
      // Best-effort: es un temporal, el sistema lo limpia igual
    }
  }

  void _markMessageAsFailed(String tempId, Emitter<ChatDetailState> emit) {
    _actualizarEstadoMensaje(tempId, 'failed', emit);
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
      case 'ERROR_PANTALLA_WHATSAPP':
        _handleErrorPantalla(event.message, emit);
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

    // Solo procesamos si pertenece a esta conversación
    if (payload.idChatCab != _currentChatCab) return;

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
      idConversacionCab: payload.idChatCab,
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
    if (payload.idChatCab != _currentChatCab) return;

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
        idConversacionCab: payload.idChatCab,
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
          idConversacionCab: payload.idChatCab,
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

    // Solo procesamos si pertenece a esta conversación (campo idNumero contiene idChatCab)
    if (payload.idChatCab != _currentChatCab) return;

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

  // ── ERROR_PANTALLA_WHATSAPP — el servidor falló al procesar el envío ───────

  void _handleErrorPantalla(
    WebSocketMessage message,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailSuccess) return;
    final currentState = state as ChatDetailSuccess;
    final payload = ErrorPantallaWhatsAppPayload.fromMessage(message);
    if (payload == null) return;
    if (payload.idChatCab != _currentChatCab) return;

    final currentMessages = List<ChatMessage>.from(currentState.messages);

    // No trae idTokenMeta — se asume el más antiguo aún pendiente de ese chat
    final pendingIndex = currentMessages.indexWhere(
      (m) =>
          m.estadoEntrega == 'wait' &&
          (m.direccionMensaje == 'ASE' || m.direccionMensaje == 'AIA'),
    );
    if (pendingIndex == -1) return;

    currentMessages[pendingIndex] = currentMessages[pendingIndex].copyWith(
      estadoEntrega: 'failed',
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

    // indexWhere (no lastIndexWhere) — sin sufijo único en nombreArchivo, dos
    // pendientes con el mismo nombre deben resolver FIFO: la primera
    // confirmación que llega matchea con el primero que se mandó, no el último.
    return messages.indexWhere((m) {
      // Solo mensajes optimistas pendientes enviados por el asesor o IA
      if (m.estadoEntrega != 'wait') return false;
      if (m.direccionMensaje != 'ASE' && m.direccionMensaje != 'AIA') {
        return false;
      }
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
          // trim/lowercase — un espacio de más en la plantilla o una
          // extensión que vuelve con distinto casing rompía la comparación
          // exacta: no matcheaba con el mensaje optimista y quedaba
          // duplicado (uno con "wait" y otro "sent" para el mismo envío).
          if (m.contenido.trim() != payload.mensaje.trim()) return false;
          if (payload.nomArchivo.isNotEmpty && m.tipoArchivo.isNotEmpty) {
            return m.tipoArchivo.trim().toLowerCase() ==
                _extractExt(payload.nomArchivo).trim().toLowerCase();
          }
          return true;

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
