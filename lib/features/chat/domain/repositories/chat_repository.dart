// lib\features\chat\domain\repositories\chat_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

abstract class ChatRepository {
  Future<InfoLead> getInfoLead(int idLead);
  Future<List<Chat>> getChats();

  Future<List<ChatMessage>> getChatMessages(
    int idLead, {
    String? idUltimoMensaje,
  });

  bool sendWhatsAppMessage(
    String mensaje,
    String idLead,
    String numero,
    String chatCab,
  );

  Future<bool> uploadAndSendFileMessage({
    required String filePath,
    required String fileName,
    required String tipo,
    required String idLead,
    required String numero,
    required String chatCab,
  });

  Future<CrudResult> updateEstado(int idLead, String idEstado);

  Future<CrudResult> updateLeadCompleto(InfoLead lead);

  Future<List<Template>> getTemplates();

  bool sendWhatsAppTemplateMessage({
    required Template template,
    required String mensajeFormateado,
    required String idLead,
    required String numero,
    required String chatCab,
    required String nombreCliente,
    required String apellidoCliente,
    required bool isExpirado,
    required bool isCerrado,
  });
}
