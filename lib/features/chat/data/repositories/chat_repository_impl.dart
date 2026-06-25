// lib/features/chat/data/repositories/chat_repository_impl.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _datasource;

  const ChatRepositoryImpl(this._datasource);

  @override
  Future<Lead> getInfoLead(int idLead) => _datasource.getInfoLead(idLead);

  @override
  Future<List<Chat>> getChats() => _datasource.getChats();

  @override
  Future<List<ChatMessage>> getChatMessages(
    int idNumero, {
    String? idUltimoMensaje,
  }) => _datasource.getChatMessages(idNumero, idUltimoMensaje: idUltimoMensaje);

  @override
  bool sendWhatsAppMessage(
    String mensaje,
    String idNumero,
    String numero,
    String chatCab,
  ) => _datasource.sendWhatsAppMessage(mensaje, idNumero, numero, chatCab);

  @override
  Future<bool> uploadAndSendFileMessage({
    required String filePath,
    required String fileName,
    required String tipo,
    required String idNumero,
    required String numero,
    required String chatCab,
  }) async {
    return _datasource.uploadAndSendFileMessage(
      filePath: filePath,
      fileName: fileName,
      tipo: tipo,
      idNumero: idNumero,
      numero: numero,
      chatCab: chatCab,
    );
  }

  @override
  Future<CrudResult> updateEstado(int idNumero, String idEstado) =>
      _datasource.updateEstado(idNumero, idEstado);

  @override
  Future<CrudResult> updateLeadCompleto(Lead lead) =>
      _datasource.updateLeadCompleto(lead);

  @override
  Future<List<Template>> getTemplates() => _datasource.getTemplates();

  @override
  bool sendWhatsAppTemplateMessage({
    required Template template,
    required String mensajeFormateado,
    required String idNumero,
    required String numero,
    required String chatCab,
    required String nombreCliente,
    required String apellidoCliente,
    required bool isExpirado,
    required bool isCerrado,
  }) => _datasource.sendWhatsAppTemplateMessage(
    template: template,
    mensajeFormateado: mensajeFormateado,
    idNumero: idNumero,
    numero: numero,
    chatCab: chatCab,
    nombreCliente: nombreCliente,
    apellidoCliente: apellidoCliente,
    isExpirado: isExpirado,
    isCerrado: isCerrado,
  );
}
