//lib\features\chat\data\datasources\remote\chat_remote_datasource.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_crm/core/index_core.dart';
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

  bool sendWhatsAppMessage(
    String mensaje,
    String idLead,
    String numero,
    String chatCab,
  ) {
    final user = _session.user;
    if (user == null) return false;

    String data =
        "${user.token}¯$idLead¦¦${user.codUser}¦$mensaje¦text¦$numero¦0¦¦$chatCab¦¦¦¦${user.codUser}¦¯CA";
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
      if (fileBytes.isEmpty) return false;

      // Extensión con punto (e.g. ".mp3", ".jpg") como lo arma el JS
      final dotIndex = fileName.lastIndexOf('.');
      final fileExt = dotIndex != -1 ? fileName.substring(dotIndex) : '';

      // Cabecera: VAR01-VAR11 separados por ¦
      // VAR01=idLead, VAR02='', VAR03=codUser, VAR04='', VAR05=tipo,
      // VAR06=numero, VAR07='0', VAR08='', VAR09=chatCab, VAR10=fileName, VAR11=fileExt
      final cabecera =
          '$idLead¦¦${user.codUser}¦¦$tipo¦$numero¦0¦¦$chatCab¦$fileName¦$fileExt';

      

      final urlUpload = ApiConstants.urlGuardarMultimedia;

      // Tamaño máximo por fragmento (igual que VI_TOPE en el JS)
      const int chunkSize = 2 * 1024 * 1024; // 2 MB
      final int totalSize = fileBytes.length;
      final int totalChunks = (totalSize / chunkSize).ceil();

      // Subir fragmentos secuencialmente (viaje 0 hasta totalChunks - 1)
      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        var end = start + chunkSize;
        if (end > totalSize) end = totalSize;

        final chunkBytes = fileBytes.sublist(start, end);

        // data = TOKEN¯cabecera¯LIST¯RF¯CONT¯TOTAL
        final dataString = '${user.token}¯$cabecera¯¯C¯$i¯$totalChunks';

        debugPrint('DATA CABECERA : $dataString');

        final result = await _api.postMultipart(
          url: urlUpload,
          fields: {'data': dataString},
          fileFieldName: 'files',
          fileBytes: chunkBytes,
          fileName: fileName,
          headers: {'Token': user.token},
        );

        if (result.isEmpty) return false;

        // Respuesta: "OK¦nroViaje"
        final datos = result.split('¦');
        if (datos[0] != 'OK') return false;
      }

      // Petición final (merge): CONT == TOTAL, archivo vacío
      // El backend une los .part0, .part1, ... y emite el WebSocket
      final mergeData = '${user.token}¯$cabecera¯¯C¯$totalChunks¯$totalChunks';

      final mergeResult = await _api.postMultipart(
        url: urlUpload,
        fields: {'data': mergeData},
        fileFieldName: 'files',
        fileBytes: <int>[],
        fileName: fileName,
        headers: {'Token': user.token},
      );

      if (mergeResult.isEmpty) return false;

      // Respuesta merge: "OK¦nroViaje¦" — cuando nroViaje == totalChunks, todo OK
      final mergeDatos = mergeResult.split('¦');
      return mergeDatos[0] == 'OK';
    } catch (e) {
      debugPrint('Error uploadAndSendFileMessage: $e');
      return false;
    }
  }
}
