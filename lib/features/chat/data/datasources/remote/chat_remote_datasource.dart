// lib/features/chat/data/datasources/remote/chat_remote_datasource.dart
//lib\features\chat\data\datasources\remote\chat_remote_datasource.dart

import 'dart:io';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/chat/index_chat.dart';

class ChatRemoteDatasource {
  final ApiClient _api = ApiClient();
  final _session = SessionService();
  final _deviceInfo = DeviceInfoService();

  final sep = AppConstants.sepListas;
  final camp = AppConstants.sepCampos;

  String _orEmpty(dynamic val) =>
      (val == null || val == 0) ? '' : val.toString();

  Future<InfoLeadModel> getInfoLead(int idLead) async {
    final String body = '${[idLead].join(camp)}${sep}D';

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
    final String body =
        '${[_session.codUser, _session.isModerador ? 1 : 0].join(camp)}${sep}L';

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
    final String body = '${[idLead, idUltimoMensaje ?? ''].join(camp)}${sep}LD';

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
    String idLead,
    String numero,
    String chatCab,
  ) {
    final user = _session.user;
    if (user == null) return false;

    final String body =
        '${user.token}$sep'
        '${[idLead, '', user.codUser, mensaje, 'text', numero, 0, '', chatCab, '', '', '', user.codUser, ''].join(camp)}'
        '${sep}CA';

    return SignalRService.instance.sendMessage("ENVIAR_WHATSAPP$sep$body");
  }

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
  }) {
    final user = _session.user;
    if (user == null) return false;

    final vars = [
      idLead, // VAR01
      template.nombre, // VAR02
      user.codUser, // VAR03
      mensajeFormateado, // VAR04
      'template', // VAR05
      numero, // VAR06
      isExpirado || isCerrado ? '1' : '0', // VAR07
      '', // VAR08
      chatCab, // VAR09
      '', // VAR10
      nombreCliente, // VAR11
      apellidoCliente, // VAR12
      _session.userApe, // VAR13
      template.detalle, // VAR14
      '${template.rutaArchivo}${template.nombreArchivo}${template.extensionArchivo}', // VAR15
      template.isBoton ? '1' : '0', // VAR16
    ].join(camp);

    final String body = '${user.token}$sep$vars${sep}CA';

    return SignalRService.instance.sendMessage("ENVIAR_WHATSAPP$sep$body");
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

      final dotIndex = fileName.lastIndexOf('.');
      final fileExt = dotIndex != -1 ? fileName.substring(dotIndex) : '';

      final cabecera = [
        idLead,
        '',
        user.codUser,
        '',
        tipo,
        numero,
        0,
        '',
        chatCab,
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
    } catch (e) {
      return false;
    }
  }

  Future<CrudResult> updateEstado(int idLead, String idEstado) async {
    final ip = await _deviceInfo.getLocalIp();

    final String body =
        '${[idLead, idEstado, _session.codUser, ip].join(camp)}${sep}UE';

    final result = await _api.postSafe(ApiConstants.urlLeadsCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  Future<CrudResult> updateLeadCompleto(InfoLead lead) async {
    final ip = await _deviceInfo.getLocalIp();

    final String body =
        '${[lead.idLead, lead.idEstado, _orEmpty(lead.idCampania), _orEmpty(lead.idEvento), _orEmpty(lead.idCanal), _orEmpty(lead.idInteres), _session.codUser, ip].join(camp)}'
        '${sep}U';

    final result = await _api.postSafe(ApiConstants.urlLeadsCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  Future<List<TemplateModel>> getTemplates() async {
    final String body = '${sep}LP';

    final result = await _api.postSafe(ApiConstants.urlChatsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => TemplateModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }
}
