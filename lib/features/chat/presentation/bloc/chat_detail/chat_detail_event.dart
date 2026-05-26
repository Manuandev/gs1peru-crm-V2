// lib\features\chat\presentation\bloc\chat_detail\chat_detail_event.dart

import 'package:app_crm/core/index_core.dart';
import 'package:equatable/equatable.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class ChatDetailIncomingMessageReceived extends ChatDetailEvent {
  final WebSocketMessage message;
  const ChatDetailIncomingMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatDetailStarted extends ChatDetailEvent {
  final int idLead;
  const ChatDetailStarted(this.idLead);

  @override
  List<Object?> get props => [idLead];
}

class ChatDetailRefreshed extends ChatDetailEvent {
  final int idLead;
  const ChatDetailRefreshed(this.idLead);

  @override
  List<Object?> get props => [idLead];
}

class ChatDetailMoreMessagesLoaded extends ChatDetailEvent {
  final int idLead;
  final String idUltimoMensaje;
  const ChatDetailMoreMessagesLoaded({
    required this.idLead,
    required this.idUltimoMensaje,
  });

  @override
  List<Object?> get props => [idLead, idUltimoMensaje];
}

class ChatDetailTextMessageSent extends ChatDetailEvent {
  final String mensaje;
  final String numero;
  final String chatCab;
  const ChatDetailTextMessageSent(this.mensaje, {this.numero = '', this.chatCab = ''});

  @override
  List<Object?> get props => [mensaje, numero, chatCab];
}

class ChatDetailAudioMessageSent extends ChatDetailEvent {
  final String audioPath;
  const ChatDetailAudioMessageSent(this.audioPath);

  @override
  List<Object?> get props => [audioPath];
}

class ChatDetailFileMessageSent extends ChatDetailEvent {
  final String filePath;
  final String fileName;
  final String fileExt;
  final String tipo; // ← agregar ('image' | 'document')

  const ChatDetailFileMessageSent({
    required this.filePath,
    required this.fileName,
    required this.fileExt,
    required this.tipo, // ← agregar
  });

  @override
  List<Object?> get props => [filePath, fileName, fileExt, tipo];
}
