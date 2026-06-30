// lib/features/chat/presentation/bloc/chat_detail/chat_detail_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

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
  final int idNumero;
  const ChatDetailStarted(this.idNumero);

  @override
  List<Object?> get props => [idNumero];
}

class ChatDetailRefreshed extends ChatDetailEvent {
  final int idNumero;
  const ChatDetailRefreshed(this.idNumero);

  @override
  List<Object?> get props => [idNumero];
}

class ChatDetailMoreMessagesLoaded extends ChatDetailEvent {
  final int idNumero;
  final String idUltimoMensaje;
  const ChatDetailMoreMessagesLoaded({
    required this.idNumero,
    required this.idUltimoMensaje,
  });

  @override
  List<Object?> get props => [idNumero, idUltimoMensaje];
}

class ChatDetailTextMessageSent extends ChatDetailEvent {
  final String mensaje;
  final String numero;
  final int idChatCab;
  const ChatDetailTextMessageSent(
    this.mensaje, {
    this.numero = '',
    required this.idChatCab,
  });

  @override
  List<Object?> get props => [mensaje, numero, idChatCab];
}

class ChatDetailTemplateMessageSent extends ChatDetailEvent {
  final Plantilla template;
  final String numero;
  final int idChatCab;
  final String nombreCliente;
  final String apellidoCliente;
  final bool isExpirado;
  final bool isCerrado;

  const ChatDetailTemplateMessageSent({
    required this.template,
    required this.numero,
    required this.idChatCab,
    required this.nombreCliente,
    required this.apellidoCliente,
    required this.isExpirado,
    required this.isCerrado,
  });

  @override
  List<Object?> get props => [
    template,
    numero,
    idChatCab,
    nombreCliente,
    apellidoCliente,
    isExpirado,
    isCerrado,
  ];
}

class ChatDetailAudioMessageSent extends ChatDetailEvent {
  final String audioPath;
  final String numero;
  final int idChatCab;
  const ChatDetailAudioMessageSent(
    this.audioPath, {
    this.numero = '',
    required this.idChatCab,
  });

  @override
  List<Object?> get props => [audioPath, numero, idChatCab];
}

class ChatDetailFileMessageSent extends ChatDetailEvent {
  final String filePath;
  final String fileName;
  final String fileExt;
  final String tipo; // ← agregar ('image' | 'document')
  final String numero;
  final int idChatCab;

  const ChatDetailFileMessageSent({
    required this.filePath,
    required this.fileName,
    required this.fileExt,
    required this.tipo, // ← agregar
    this.numero = '',
    required this.idChatCab,
  });

  @override
  List<Object?> get props => [
    filePath,
    fileName,
    fileExt,
    tipo,
    numero,
    idChatCab,
  ];
}

class ChatDetailBatchFileMessageSent extends ChatDetailEvent {
  final List<StagedFile> files;
  final String numero;
  final int idChatCab;

  const ChatDetailBatchFileMessageSent({
    required this.files,
    this.numero = '',
    required this.idChatCab,
  });

  @override
  List<Object?> get props => [files, numero, idChatCab];
}
