// lib\features\chat\presentation\bloc\chat_detail\chat_detail_event.dart

import 'package:equatable/equatable.dart';

abstract class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class ChatDetailStarted extends ChatDetailEvent {
  final String idLead;
  const ChatDetailStarted(this.idLead);

  @override
  List<Object?> get props => [idLead];
}

class ChatDetailRefreshed extends ChatDetailEvent {
  final String idLead;
  const ChatDetailRefreshed(this.idLead);

  @override
  List<Object?> get props => [idLead];
}

class ChatDetailMoreMessagesLoaded extends ChatDetailEvent {
  final String idLead;
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
  const ChatDetailTextMessageSent(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
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
