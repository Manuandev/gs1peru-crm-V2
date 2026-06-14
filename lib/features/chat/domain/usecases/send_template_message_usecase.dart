// lib/features/chat/domain/usecases/send_template_message_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class SendTemplateMessageUseCase {
  final ChatRepository _repository;

  const SendTemplateMessageUseCase(this._repository);

  bool call({
    required Template template,
    required String mensajeFormateado,
    required String idLead,
    required String numero,
    required String chatCab,
    required String nombreCliente,
    required String apellidoCliente,
    required bool isExpirado,
    required bool isCerrado,
  }) {
    return _repository.sendWhatsAppTemplateMessage(
      template: template,
      mensajeFormateado: mensajeFormateado,
      idLead: idLead,
      numero: numero,
      chatCab: chatCab,
      nombreCliente: nombreCliente,
      apellidoCliente: apellidoCliente,
      isExpirado: isExpirado,
      isCerrado: isCerrado,
    );
  }
}