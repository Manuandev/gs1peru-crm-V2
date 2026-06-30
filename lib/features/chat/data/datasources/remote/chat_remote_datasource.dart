// lib/features/chat/data/datasources/remote/chat_remote_datasource.dart
//lib\features\chat\data\datasources\remote\chat_remote_datasource.dart

import 'dart:io';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class ChatRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  Lead _parsePrimerLead(String seccion) {
    final leads = LeadModel.parseList(seccion);
    if (leads.isEmpty) {
      throw const AppException('No se encontró información del lead.');
    }
    return leads.first;
  }

  Future<Lead> getInfoLead(int idLead) async {
    final String body = '${[idLead].join(camp)}${sep}DT';

    final result = await _api.postSafe(ApiConstants.urlLeadsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => _parsePrimerLead(data),
      ApiEmpty() => throw const AppException(
        'No se encontró información del lead.',
      ),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<ChatModel>> getChats() async {
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(camp)}${sep}LS';

    final result = await _api.postSafe(ApiConstants.urlChatsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ChatModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  Future<List<ChatMessageModel>> getChatMessages(
    int idNumero, {
    String? idUltimoMensaje, // null = primera carga
  }) async {
    final String body =
        '${[idNumero, idUltimoMensaje ?? ''].join(camp)}${sep}DT';

    final result = await _api.postSafe(ApiConstants.urlChatsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ChatMessageModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  bool sendWhatsAppMessage(
    String mensaje,
    String idNumero,
    String numero,
    int idChatCab,
  ) {
    final user = _session.user;
    if (user == null) return false;

    final String body =
        '${user.token}$sep'
        '${[idChatCab, '', user.codUser, mensaje, 'text', numero, 0, '', idChatCab, '', '', '', user.codUser, ''].join(camp)}'
        '${sep}CA';

    return SignalRService.instance.sendMessage("ENVIAR_WHATSAPP$sep$body");
  }

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
  }) {
    final user = _session.user;
    if (user == null) return false;

    final vars = [
      idChatCab, // VAR01
      plantilla.nombre, // VAR02
      user.codUser, // VAR03
      mensajeFormateado, // VAR04
      'template', // VAR05
      numero, // VAR06
      isExpirado || isCerrado ? '1' : '0', // VAR07
      '', // VAR08
      idChatCab, // VAR09
      '', // VAR10
      nombreCliente, // VAR11
      apellidoCliente, // VAR12
      _session.userApe, // VAR13
      plantilla.contenido, // VAR14
      '', // VAR15 — archivo (no aplica en SP actual)
      '0', // VAR16 — isBoton (no aplica en SP actual)
    ].join(camp);

    final String body = '${user.token}$sep$vars${sep}CA';

    return SignalRService.instance.sendMessage("ENVIAR_WHATSAPP$sep$body");
  }

  Future<bool> uploadAndSendFileMessage({
    required String filePath,
    required String fileName,
    required String tipo,
    required String idNumero,
    required String numero,
    required int idChatCab,
  }) async {
    final user = _session.user;
    if (user == null) return false;

    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      if (fileBytes.isEmpty) return false;

      final dotIndex = fileName.lastIndexOf('.');
      final fileExt = dotIndex != -1 ? fileName.substring(dotIndex) : '';

      final cabecera = [
        idChatCab,
        '',
        user.codUser,
        '',
        tipo,
        numero,
        0,
        '',
        idChatCab,
        fileName,
        fileExt,
      ].join(camp);

      final urlUpload = ApiConstants.urlGuardarMultimedia;

      const int chunkSize = 2 * 1024 * 1024;
      final int totalSize = fileBytes.length;
      final int totalChunks = (totalSize / chunkSize).ceil();

      for (int i = 0; i < totalChunks; i++) {
        final start = i * chunkSize;
        var end = start + chunkSize;
        if (end > totalSize) end = totalSize;

        final chunkBytes = fileBytes.sublist(start, end);

        final dataString = [
          user.token,
          cabecera,
          '',
          'C',
          i,
          totalChunks,
        ].join(sep);

        final result = await _api.postMultipart(
          url: urlUpload,
          fields: {'data': dataString},
          fileFieldName: 'files',
          fileBytes: chunkBytes,
          fileName: fileName,
          headers: {'Token': user.token},
        );

        if (result.isEmpty) return false;

        final datos = result.split(camp);
        if (datos[0] != 'OK') return false;
      }

      final mergeData = [
        user.token,
        cabecera,
        '',
        'C',
        totalChunks,
        totalChunks,
      ].join(sep);

      final mergeResult = await _api.postMultipart(
        url: urlUpload,
        fields: {'data': mergeData},
        fileFieldName: 'files',
        fileBytes: <int>[],
        fileName: fileName,
        headers: {'Token': user.token},
      );

      if (mergeResult.isEmpty) return false;

      final mergeDatos = mergeResult.split(camp);
      return mergeDatos[0] == 'OK';
    } catch (_) {
      return false;
    }
  }

  Future<CrudResult> updateEstado(int idNumero, String idEstado) async {
    final ip = await _deviceInfo.getLocalIp();

    final String body =
        '${[idNumero, idEstado, _session.codUser, ip].join(camp)}${sep}UE';

    final result = await _api.postSafe(ApiConstants.urlLeadsCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  Future<List<PlantillaModel>> getTemplates() async {
    final String body = '${sep}LP';

    final result = await _api.postSafe(ApiConstants.urlChatsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => PlantillaModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
