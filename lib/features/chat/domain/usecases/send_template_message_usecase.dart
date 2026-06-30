// lib/features/chat/domain/usecases/send_template_message_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class SendTemplateMessageUseCase {
  final ChatRepository _repository;

  const SendTemplateMessageUseCase(this._repository);

  bool call({
    required Plantilla plantilla,
    required String mensajeFormateado,
    required String idNumero,
    required String numero,
    required int chatCab,
    required String nombreCliente,
    required String apellidoCliente,
    required bool isExpirado,
    required bool isCerrado,
  }) {
    return _repository.sendWhatsAppTemplateMessage(
      plantilla: plantilla,
      mensajeFormateado: mensajeFormateado,
      idNumero: idNumero,
      numero: numero,
      idChatCab: chatCab,
      nombreCliente: nombreCliente,
      apellidoCliente: apellidoCliente,
      isExpirado: isExpirado,
      isCerrado: isCerrado,
    );
  }
}