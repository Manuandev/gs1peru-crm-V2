// lib/core/services/app_update_service.dart
//
// Chequea si hay una versión nueva publicada en ApiConstants.urlVersionCheck
// — host de archivos aparte del backend del CRM, así que usa un Dio propio
// en vez de ApiClient (evita los interceptores pensados para la API del CRM,
// como TokenBodyInterceptor). Se llama una sola vez por arranque de la app,
// desde SplashBloc, en paralelo a la carga de configuración.
//
// El resultado queda en memoria (para LoginView y el gate de guardado, sin
// otra llamada a la URL) y también se respalda en SQLite — por si Android
// mata el proceso en segundo plano y lo revive sin volver a pasar por
// Splash, [obtenerPendiente] igual encuentra el dato. Ver auth/CLAUDE.md.

import 'package:dio/dio.dart';

import 'package:app_crm/core/constants/api_constants.dart';
import 'package:app_crm/core/constants/app_constants.dart';
import 'package:app_crm/core/database/local_database.dart';
import 'package:app_crm/core/models/update_info.dart';
import 'package:app_crm/core/utils/version_utils.dart';

class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService _instance = AppUpdateService._();
  factory AppUpdateService() => _instance;

  static const _settingKey = 'update_pendiente';

  UpdateInfo? _actualizacionPendiente;
  bool _yaVerificado = false;

  /// Solo para lectura síncrona inmediata (ej. builds) — puede quedar null
  /// un instante aunque haya una pendiente respaldada en SQLite todavía sin
  /// cargar a memoria. Preferir [obtenerPendiente] en cualquier chequeo que
  /// decida bloquear algo (login, guardado).
  UpdateInfo? get actualizacionPendiente => _actualizacionPendiente;

  /// Fuente única de verdad para decidir si se bloquea una acción — primero
  /// memoria (ya seteada si el proceso pasó por [verificar] esta sesión),
  /// si no, respaldo en SQLite.
  Future<UpdateInfo?> obtenerPendiente() async {
    if (_yaVerificado) return _actualizacionPendiente;

    final raw = await LocalDatabase().getSetting(_settingKey);
    _actualizacionPendiente = _decodificar(raw);
    return _actualizacionPendiente;
  }

  /// Fire-and-forget seguro — cualquier error de red queda contenido acá,
  /// nunca bloquea el arranque de la app. Llamar una sola vez por sesión
  /// (SplashBloc) — sucesivos chequeos (login, guardado) usan
  /// [obtenerPendiente], que no vuelve a golpear la URL.
  Future<void> verificar() async {
    try {
      final dio = Dio();
      final response = await dio.get<Map<String, dynamic>>(
        ApiConstants.urlVersionCheck,
        options: Options(
          responseType: ResponseType.json,
          sendTimeout: ApiConstants.connectionTimeout,
          receiveTimeout: ApiConstants.receiveTimeout,
        ),
      );

      final data = response.data;
      if (data == null) return;

      final info = UpdateInfo.fromJson(data);
      if (info.version.isEmpty || info.downloadUrl.isEmpty) return;

      if (VersionUtils.esMenor(AppConstants.version, info.version)) {
        _actualizacionPendiente = info;
        await LocalDatabase().setSetting(_settingKey, _codificar(info));
      } else {
        // Ya está al día — limpia un flag viejo (ej. el usuario acaba de
        // actualizar) para que no quede bloqueando de por vida.
        _actualizacionPendiente = null;
        await LocalDatabase().deleteSetting(_settingKey);
      }
      _yaVerificado = true;
    } catch (_) {
      // Sin conexión o servidor caído — no bloquea el login, se reintenta
      // en el próximo arranque de la app. _yaVerificado queda false a
      // propósito, así obtenerPendiente() cae al respaldo de SQLite.
    }
  }

  String _codificar(UpdateInfo info) => [
    info.version,
    info.downloadUrl,
    info.releaseDate,
  ].join(AppConstants.sepCampos);

  UpdateInfo? _decodificar(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final partes = raw.split(AppConstants.sepCampos);
    if (partes.length < 2) return null;
    return UpdateInfo(
      version: partes[0],
      downloadUrl: partes[1],
      releaseDate: partes.length > 2 ? partes[2] : '',
    );
  }
}
