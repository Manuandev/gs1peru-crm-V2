//lib\features\chat\data\datasources\remote\chat_remote_datasource.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/core/network/api_result.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();

  Future<InfoLeadModel> getInfoLead(int idLead) async {
    final String body = '$idLead¯D';

    final result = await _api.postSafe(ApiConstants.urlChatsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => InfoLeadModel.parse(data),
      ApiEmpty() => throw const AppException(
        'No se encontró información del lead.',
      ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<ChatModel>> getChats() async {
    final String body = '${_session.codUser}¯L';

    final result = await _api.postSafe(ApiConstants.urlChatsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ChatModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<ChatMessageModel>> getChatMessages(
    int idLead, {
    String? idUltimoMensaje, // null = primera carga
  }) async {
    final result = await _api.postSafe(
      ApiConstants.urlChatsLst,
      '$idLead¦${idUltimoMensaje ?? ''}¯LD',
    );

    return switch (result) {
      ApiSuccess(:final data) => ChatMessageModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  bool sendWhatsAppMessage(String mensaje, String idLead, String numero, String chatCab) {
    final user = _session.user;
    if (user == null) return false;

    String data = "${user.token}¯$idLead¦¦${user.codUser}¦$mensaje¦text¦$numero¦0¦¦$chatCab¦¦¦¦${user.codUser}¦¯CA";
    return SignalRService.instance.sendMessage("ENVIAR_WHATSAPP¯$data");
  }

  Future<bool> uploadAndSendFileMessage({
    required String filePath,
    required String fileName,
    required String tipo,
    required String idLead,
    required String numero,
    required String chatCab,
  }) async {
    final user = _session.user;
    if (user == null) return false;

    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();

      // 1. Subir a la base de datos usando multipart
      final urlUpload = ApiConstants.urlGuardarMultimedia; 

      final uploadResult = await _api.postMultipart(
        url: urlUpload,
        fields: {
          'idLead': idLead,
          'codUser': user.codUser,
          'tipo': tipo,
          'chatCab': chatCab,
        },
        fileFieldName: 'file', // Cambia esto si tu backend espera otro nombre
        fileBytes: fileBytes,
        fileName: fileName,
        headers: {'Token': user.token},
      );

      // Si el servidor retorna vacío (o si tu lógica considera que falló)
      if (uploadResult.isEmpty) {
        return false;
      }

      // 2. Si la subida fue exitosa, enviamos el mensaje por socket.
      // NOTA: Ajusta esta trama según lo que espere el backend para archivos (ej. pasando el fileName)
      String data = "${user.token}¯$idLead¦¦${user.codUser}¦¦$tipo¦$numero¦0¦¦$chatCab¦¦¦$fileName¦${user.codUser}¦¯CA";
      return SignalRService.instance.sendMessage("ENVIAR_WHATSAPP¯$data");
    } catch (e) {
      debugPrint('Error uploadAndSendFileMessage: $e');
      return false;
    }
  }
}
