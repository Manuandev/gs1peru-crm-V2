// lib/features/chat/presentation/bloc/chat_detail/chat_detail_event.dart
//
// PROPÓSITO:
//   Define todas las intenciones del usuario en el chat de detalle.
//   Los eventos son inmutables y no contienen lógica.
//
// IMPORTANTE:
//   Los eventos usan [FileAttachment] (entidad de dominio), NO [PlatformFile].
//   La conversión ocurre en la View antes de despachar el evento.
//
// MAPA DE EVENTOS:
//   ┌──────────────────────────────────────────────────────┐
//   │ CICLO DE VIDA                                        │
//   │  ChatDetailStarted         primera carga             │
//   │  ChatDetailRefreshed       pull-to-refresh           │
//   │  ChatDetailLoadMore        scroll al tope            │
//   ├──────────────────────────────────────────────────────┤
//   │ GRABACIÓN DE AUDIO                                   │
//   │  ChatDetailRecordingStarted  presionar micrófono     │
//   │  ChatDetailRecordingFinished liberar para enviar     │
//   │  ChatDetailRecordingCancelled presionar cancelar     │
//   ├──────────────────────────────────────────────────────┤
//   │ ARCHIVOS                                             │
//   │  ChatDetailFilesSelected   elegir archivos adjuntos  │
//   │  ChatDetailFileRemoved     quitar uno del preview    │
//   │  ChatDetailFilesSent       confirmar envío           │
//   ├──────────────────────────────────────────────────────┤
//   │ ENVÍO DE TEXTO                                       │
//   │  ChatDetailMessageSent     presionar enviar texto    │
//   ├──────────────────────────────────────────────────────┤
//   │ CONTACTO                                             │
//   │  ChatDetailFavoriteToggled presionar estrella        │
//   └──────────────────────────────────────────────────────┘

import 'package:app_crm/features/chat/domain/entities/file_attachment.dart';
import 'package:equatable/equatable.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();
  @override
  List<Object?> get props => [];
}

// ============================================================
// CICLO DE VIDA
// ============================================================

/// Se dispara cuando se abre el chat por primera vez.
/// Resetea todo el estado y carga los mensajes más recientes.
class ChatDetailStarted extends ChatDetailEvent {
  final String idLead;
  const ChatDetailStarted(this.idLead);
  @override
  List<Object?> get props => [idLead];
}

/// Se dispara al hacer pull-to-refresh.
/// Recarga desde el inicio sin paginación.
class ChatDetailRefreshed extends ChatDetailEvent {
  const ChatDetailRefreshed();
}

/// Se dispara cuando el scroll llega al tope.
/// Carga mensajes más antiguos (paginación hacia el pasado).
class ChatDetailLoadMore extends ChatDetailEvent {
  const ChatDetailLoadMore();
}

// ============================================================
// GRABACIÓN DE AUDIO
// ============================================================

/// El usuario presionó el botón de micrófono.
/// El BLoC solicita permiso e inicia la grabación vía AudioRecorderService.
class ChatDetailRecordingStarted extends ChatDetailEvent {
  const ChatDetailRecordingStarted();
}

/// El usuario presionó "Enviar" durante la grabación.
/// El BLoC detiene la grabación y envía el audio.
class ChatDetailRecordingFinished extends ChatDetailEvent {
  const ChatDetailRecordingFinished();
}

/// El usuario presionó "Cancelar" durante la grabación.
/// El BLoC detiene y descarta el archivo sin enviarlo.
class ChatDetailRecordingCancelled extends ChatDetailEvent {
  const ChatDetailRecordingCancelled();
}

// ============================================================
// ARCHIVOS ADJUNTOS
// ============================================================

/// El usuario seleccionó archivos del file picker.
/// La View convierte PlatformFile → FileAttachment antes de despachar.
///
/// El BLoC los guarda en el estado para mostrar el preview.
class ChatDetailFilesSelected extends ChatDetailEvent {
  final List<FileAttachment> files;
  const ChatDetailFilesSelected(this.files);
  @override
  List<Object?> get props => [files];
}

/// El usuario tocó la X de un archivo en el preview.
class ChatDetailFileRemoved extends ChatDetailEvent {
  final int index;
  const ChatDetailFileRemoved(this.index);
  @override
  List<Object?> get props => [index];
}

/// El usuario confirmó el envío de los archivos en preview.
class ChatDetailFilesSent extends ChatDetailEvent {
  final String numero;
  final String chatCab;
  const ChatDetailFilesSent({
    required this.numero,
    required this.chatCab,
  });
  @override
  List<Object?> get props => [numero, chatCab];
}

// ============================================================
// ENVÍO DE TEXTO
// ============================================================

/// El usuario presionó "Enviar" con texto en el input.
class ChatDetailMessageSent extends ChatDetailEvent {
  final String texto;
  final String numero;
  final String chatCab;
  const ChatDetailMessageSent({
    required this.texto,
    required this.numero,
    required this.chatCab,
  });
  @override
  List<Object?> get props => [texto, numero, chatCab];
}

// ============================================================
// CONTACTO
// ============================================================

/// El usuario tocó la estrella de favorito.
/// [esActualFav] → estado ACTUAL (el BLoC calcula el nuevo valor).
class ChatDetailFavoriteToggled extends ChatDetailEvent {
  final String idLead;
  final bool esActualFav;
  const ChatDetailFavoriteToggled({
    required this.idLead,
    required this.esActualFav,
  });
  @override
  List<Object?> get props => [idLead, esActualFav];
}