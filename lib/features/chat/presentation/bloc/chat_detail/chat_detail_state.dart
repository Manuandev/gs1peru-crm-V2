// lib/features/chat/presentation/bloc/chat_detail/chat_detail_state.dart
//
// PROPÓSITO:
//   Define el estado completo del chat de detalle.
//   Un único ChatDetailSuccess con todo adentro — elimina la necesidad
//   de variables globales (isRecording, archivosSeleccionados, etc.)
//
// DISEÑO:
//   Se usa un único estado de éxito (ChatDetailSuccess) en lugar de
//   múltiples estados para diferentes modos de input. Esto evita
//   "state explosion" y simplifica los BlocBuilder en la UI.
//
//   El InputMode dentro del estado describe qué muestra el área de input:
//   - text       → input de texto normal
//   - recording  → barra de grabación activa
//   - filePreview → preview de archivos seleccionados
//   - sending    → enviando (input deshabilitado)

import 'package:app_crm/features/chat/domain/entities/chat_message.dart';
import 'package:app_crm/features/chat/domain/entities/file_attachment.dart';
import 'package:equatable/equatable.dart';

// ============================================================
// ENUM: MODO DEL INPUT
// ============================================================

/// Controla qué se muestra en el área inferior del chat.
enum InputMode {
  /// Input de texto normal (estado por defecto)
  text,

  /// Grabando audio — muestra la barra roja con botones de enviar/cancelar
  recording,

  /// Archivos seleccionados — muestra el preview de adjuntos
  filePreview,

  /// Enviando contenido — input deshabilitado, sin interacción
  sending,
}

// ============================================================
// ESTADOS
// ============================================================

abstract class ChatDetailState extends Equatable {
  const ChatDetailState();
  @override
  List<Object?> get props => [];
}

/// Estado inicial antes de cualquier carga.
class ChatDetailInitial extends ChatDetailState {
  const ChatDetailInitial();
}

/// Carga inicial (primera vez que se abre el chat).
/// La UI muestra spinner central.
class ChatDetailLoading extends ChatDetailState {
  const ChatDetailLoading();
}

/// Cargando mensajes más antiguos (paginación).
/// La UI mantiene los mensajes visibles y muestra
/// un spinner pequeño en el tope de la lista.
class ChatDetailLoadingMore extends ChatDetailState {
  final List<ChatMessage> messages;
  final bool esFavorito;

  const ChatDetailLoadingMore({
    required this.messages,
    this.esFavorito = false,
  });

  @override
  List<Object?> get props => [messages, esFavorito];
}

/// ─────────────────────────────────────────────────────────────
/// ESTADO PRINCIPAL: Chat listo con todos los datos
/// ─────────────────────────────────────────────────────────────
///
/// Este es el único estado "activo" del chat. Contiene TODO:
/// los mensajes, el modo del input, los archivos en preview,
/// y el estado del favorito.
///
/// Usar [copyWith] para mutaciones parciales en el BLoC.
class ChatDetailSuccess extends ChatDetailState {
  /// Lista completa de mensajes en pantalla (más reciente al final)
  final List<ChatMessage> messages;

  /// false = ya no hay mensajes anteriores, ocultar spinner de paginación
  final bool hasMore;

  /// Estado actual del favorito del contacto
  final bool esFavorito;

  /// Controla qué se muestra en el área de input
  final InputMode inputMode;

  /// Archivos seleccionados pendientes de envío (estado filePreview)
  final List<FileAttachment> pendingFiles;

  const ChatDetailSuccess({
    required this.messages,
    this.hasMore = true,
    this.esFavorito = false,
    this.inputMode = InputMode.text,
    this.pendingFiles = const [],
  });

  // ── Getters de conveniencia ──────────────────────────────────

  /// ¿Se está enviando algo? (texto, audio o archivos)
  bool get isSending => inputMode == InputMode.sending;

  /// ¿Está grabando audio?
  bool get isRecording => inputMode == InputMode.recording;

  /// ¿Hay archivos en preview?
  bool get hasFilePreviews =>
      inputMode == InputMode.filePreview && pendingFiles.isNotEmpty;

  // ── copyWith ────────────────────────────────────────────────

  /// Crea una copia del estado con los campos especificados modificados.
  ///
  /// Ejemplo en el BLoC:
  /// ```dart
  /// emit(currentState.copyWith(inputMode: InputMode.sending));
  /// ```
  ChatDetailSuccess copyWith({
    List<ChatMessage>? messages,
    bool? hasMore,
    bool? esFavorito,
    InputMode? inputMode,
    List<FileAttachment>? pendingFiles,
  }) {
    return ChatDetailSuccess(
      messages: messages ?? this.messages,
      hasMore: hasMore ?? this.hasMore,
      esFavorito: esFavorito ?? this.esFavorito,
      inputMode: inputMode ?? this.inputMode,
      pendingFiles: pendingFiles ?? this.pendingFiles,
    );
  }

  @override
  List<Object?> get props => [
        messages,
        hasMore,
        esFavorito,
        inputMode,
        pendingFiles,
      ];

  @override
  String toString() =>
      'ChatDetailSuccess('
      'messages: ${messages.length}, '
      'inputMode: $inputMode, '
      'esFavorito: $esFavorito, '
      'pendingFiles: ${pendingFiles.length}'
      ')';
}

// ─────────────────────────────────────────────────────────────

/// Alguna operación falló.
///
/// La Page escucha este estado con BlocListener y muestra un SnackBar.
/// El estado de éxito previo se restaura automáticamente (el BLoC
/// vuelve a emitir el estado anterior después del failure).
class ChatDetailFailure extends ChatDetailState {
  final String message;
  const ChatDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}