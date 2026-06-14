// lib/features/chat/data/repositories/chat_repository_impl.dart
//lib\features\chat\data\repositories\chat_repository_impl.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource _datasource;

  const ChatRepositoryImpl(this._datasource);

  @override
  Future<InfoLead> getInfoLead(int idLead) => _datasource.getInfoLead(idLead);

  @override
  Future<List<Chat>> getChats() => _datasource.getChats();

  @override
  Future<List<ChatMessage>> getChatMessages(
    int idLead, {
    String? idUltimoMensaje,
  }) => _datasource.getChatMessages(idLead, idUltimoMensaje: idUltimoMensaje);

  @override
  bool sendWhatsAppMessage(
    String mensaje,
    String idLead,
    String numero,
    String chatCab,
  ) => _datasource.sendWhatsAppMessage(mensaje, idLead, numero, chatCab);

  @override
  Future<bool> uploadAndSendFileMessage({
    required String filePath,
    required String fileName,
    required String tipo,
    required String idLead,
    required String numero,
    required String chatCab,
  }) async {
    return _datasource.uploadAndSendFileMessage(
      filePath: filePath,
      fileName: fileName,
      tipo: tipo,
      idLead: idLead,
      numero: numero,
      chatCab: chatCab,
    );
  }

  @override
  Future<CrudResult> updateEstado(int idLead, String idEstado) =>
      _datasource.updateEstado(idLead, idEstado);

  @override
  Future<CrudResult> updateLeadCompleto(InfoLead lead) =>
      _datasource.updateLeadCompleto(lead);

  @override
  Future<List<Template>> getTemplates() => _datasource.getTemplates();

  @override
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
  }) => _datasource.sendWhatsAppTemplateMessage(
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
