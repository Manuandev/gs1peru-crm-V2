// lib/features/chat/domain/repositories/chat_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

abstract class ChatRepository {
  Future<Negociacion> getInfoNegociacion(int idLead);
  Future<List<Chat>> getChats();
  Future<Chat?> getChatByIdChatCab(int idChatCab);

  Future<List<ChatMessage>> getChatMessages(
    int idNumero, {
    String? idUltimoMensaje,
  });

  bool sendWhatsAppMessage(
    String mensaje,
    String idNumero,
    String numero,
    int idChatCab,
  );

  Future<bool> uploadAndSendFileMessage({
    required String filePath,
    required String fileName,
    required String tipo,
    required String idNumero,
    required String numero,
    required int idChatCab,
  });

  Future<CrudResult> updateEstado(int idNumero, String idEstado);

  Future<List<Plantilla>> getPlantillas();

  Future<Plantilla> getPlantilla(int idPlantilla);

  Future<CrudResult> guardarPlantilla(Plantilla plantilla);

  bool sendWhatsAppTemplateMessage({
    required Plantilla plantilla,
    required String mensajeFormateado,
    required String idNumero,
    required String numero,
    required int idChatCab,
    required String nombreCliente,
    required String apellidoCliente,
    required bool isExpirado,
    required bool isCerrado,
  });
}
