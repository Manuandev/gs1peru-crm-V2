import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/core/services/device_info_service.dart';
import 'package:app_crm/features/asistente/data/models/asistente_chat.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AsistenteRepositorio {
  static const _sep = '¦';
  static const _sepReg = '¬';
  static const _sepLista = '¯';

  Future<bool> guardarHistorial({required List<AsistenteChat> mensajes}) async {
    final usuario = SessionService().user;
    if (usuario == null || mensajes.isEmpty) return false;

    final ip = await DeviceInfoService().getLocalIp();
    final lstData = [usuario.userId, ip].join(_sep);

    final historial = <String>[];
    for (var i = 0; i < mensajes.length; i++) {
      final msg = mensajes[i];
      final esIa = msg.remitente == RemitenteChat.ia;
      historial.add(
        '${i + 1}$_sep$_sep${esIa ? 'IA' : 'USUARIO'}$_sep${esIa ? '' : usuario.userId}$_sep${msg.texto}',
      );
    }

    final payload =
        '${usuario.token}$_sepLista$lstData$_sepLista${historial.join(_sepReg)}${_sepLista}CHIA';
    final payloadEscapado = payload
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r');

    debugPrint('📤 PAYLOAD: $payload');

    try {
      // final res = await DioClient.instancia.post<String>(
      //   '/Asistente/asistenteCudAPP',
      //   data: '"$payloadEscapado"',
      //   options: Options(headers: {'Content-Type': 'application/json'}),
      // );
      // return res.data?.startsWith('OK') ?? false;
      // return true;
    } catch (_) {
      // return false;
    }
    return false;
  }
}
