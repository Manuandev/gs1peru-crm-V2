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

  Negociacion _parsePrimerLead(String seccion) {
    final negociaciones = NegociacionModel.parseDetalleList(seccion);
    if (negociaciones.isEmpty) {
      throw const AppException('No se encontró información del lead.');
    }
    return negociaciones.first;
  }

  Future<Negociacion> getInfoNegociacion(int idLead) async {
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

  /// Trae un único chat por su ID_CONVERSACION_CAB — usado cuando llega un
  /// mensaje por WebSocket de una conversación que aún no está en memoria.
  Future<Chat?> getChatByIdChatCab(int idChatCab) async {
    final String body = '$idChatCab${sep}LU';

    final result = await _api.postSafe(ApiConstants.urlChatsLst, body);

    return switch (result) {
      ApiSuccess(:final data) => ChatModel.parseList(data).firstOrNull,
      ApiEmpty() => null,
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
      '${plantilla.archivoNombre}${plantilla.archivoExt}', // VAR15
      plantilla.tieneBoton ? '1' : '0', // VAR16
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

    final result = await _api.postSafe(ApiConstants.urlPlantillasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => PlantillaModel.parseList(data),
      ApiEmpty() => [],
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // ── Gestión de plantillas (crear/editar) ──────────────────────────────────
  // El task 'DP' (detalle de una plantilla) es provisional — el SP
  // (CRM.CSV_PLANTILLA_LST_APP) todavía no tiene esa rama, solo 'LP'. Se deja
  // escrito con el mismo patrón que getInfoNegociacion('DT') para no
  // reinventar el formato de body cuando ese endpoint exista — TemplateFormBloc
  // no lo invoca todavía (ver _onStarted).

  Future<PlantillaModel> getPlantilla(int idPlantilla) async {
    final String body = '${[idPlantilla].join(camp)}${sep}DP';

    final result = await _api.postSafe(ApiConstants.urlPlantillasLst, body);

    return switch (result) {
      ApiSuccess(:final data) => PlantillaModel.fromRawString(data),
      ApiEmpty() => throw const AppException('Plantilla no encontrada.'),
      ApiNoInternet() => throw const AppException('Sin conexión a Internet.'),
      ApiError(:final message) => throw AppException(message),
    };
  }

  // Task 'U' — CRM.CSV_PLANTILLA_CUD_APP. Cabecera (@L_DATA, 14 campos):
  // idPlantilla¦nombre¦contenido¦idCampania¦idOportunidad¦idEstadoNegociacion¦
  // activo¦compartir¦archivoRuta¦archivoNombre¦archivoExt¦codUser¦ip¦coords.
  // Botones van en una sección aparte (@L_DATA_BTN) — solo el texto de cada
  // uno, separados por sepRegistros (el SP los reemplaza todos en cada
  // guardado, no hace falta mandar ids). idMeta/estadoMeta no se mandan — los
  // puebla la sincronización con Meta, no este formulario.
  Future<CrudResult> guardarPlantilla(Plantilla plantilla) async {
    final ip = await _deviceInfo.getLocalIp();
    final coords = await _deviceInfo.getCoordenadasString();

    final cabecera = [
      plantilla.idPlantilla,
      plantilla.nombre,
      plantilla.contenido,
      plantilla.idCampania,
      plantilla.idOportunidad,
      plantilla.idEstadoNegociacion,
      plantilla.activo ? 1 : 0,
      plantilla.compartir ? 1 : 0,
      plantilla.archivoRuta,
      plantilla.archivoNombre,
      plantilla.archivoExt,
      _session.codUser,
      ip,
      coords,
    ].join(camp);

    final botones = plantilla.botones.join(AppConstants.sepRegistros);

    final String body = [cabecera, 'U', botones].join(sep);

    final result = await _api.postSafe(ApiConstants.urlPlantillasCud, body);

    return switch (result) {
      ApiSuccess(:final data) => parseCrudResponse(data),
      ApiEmpty() => const CrudEmpty(),
      ApiNoInternet() => const CrudNoInternet(),
      ApiError(:final message) => CrudError(message),
    };
  }

  // Sube el adjunto (imagen/documento/audio) del formulario de plantillas —
  // mismo mecanismo por chunks de uploadAndSendFileMessage, pero sin
  // idLead/idChatCab (una plantilla no pertenece a ninguna conversación).
  // uploadToken se genera acá mismo y viaja igual en todos los chunks de esta
  // subida — es la carpeta estable que usa el controller entre llamadas,
  // necesaria porque en modo "crear" todavía no existe un ID_PLANTILLA.
  Future<({String ruta, String nombre, String ext})?> subirArchivoPlantilla({
    required String filePath,
    required String fileName,
    required String tipo,
  }) async {
    final user = _session.user;
    if (user == null) return null;

    try {
      final file = File(filePath);
      final fileBytes = await file.readAsBytes();
      if (fileBytes.isEmpty) return null;

      final dotIndex = fileName.lastIndexOf('.');
      final fileExt = dotIndex != -1 ? fileName.substring(dotIndex) : '';
      final uploadToken = DateTime.now().microsecondsSinceEpoch.toString();

      final cabecera = [fileName, fileExt, tipo, uploadToken].join(camp);

      final urlUpload = ApiConstants.urlGuardarMultimediaPlantilla;

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

        if (result.isEmpty) return null;

        final datos = result.split(camp);
        if (datos[0] != 'OK') return null;
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

      if (mergeResult.isEmpty) return null;

      final mergeDatos = mergeResult.split(camp);
      if (mergeDatos[0] != 'OK' || mergeDatos.length < 4) return null;

      return (ruta: mergeDatos[1], nombre: mergeDatos[2], ext: mergeDatos[3]);
    } catch (_) {
      return null;
    }
  }
}
