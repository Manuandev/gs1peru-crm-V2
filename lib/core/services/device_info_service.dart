// lib/core/services/device_info_service.dart

import 'dart:async';
import 'dart:io';
import 'package:app_crm/core/index_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';

// ── MODELO DE UBICACIÓN COMPLETA (geocodificación inversa) ───
// Resultado de getUbicacionCompleta() — dirección real desde GPS
class UbicacionResult {
  final String pais; // 'Perú'
  final String paisCodigo; // 'PE'
  final String region; // 'Lima'               (departamento/estado)
  final String provincia; // 'Lima Province'       (provincia)
  final String ciudad; // 'Lima'
  final String distrito; // 'Miraflores'
  final String calle; // 'Av. Larco'
  final String numero; // '345'
  final String codigoPostal; // '15074'
  final String subLocality; // Barrio/urbanización (si lo provee)
  final String error;
  final bool hasData;

  const UbicacionResult({
    this.pais = '',
    this.paisCodigo = '',
    this.region = '',
    this.provincia = '',
    this.ciudad = '',
    this.distrito = '',
    this.calle = '',
    this.numero = '',
    this.codigoPostal = '',
    this.subLocality = '',
    this.error = '',
    this.hasData = false,
  });

  /// Dirección completa en una línea.
  /// Ejemplo: 'Av. Larco 345, Miraflores, Lima, Perú'
  String get direccionCompleta {
    final partes = <String>[];
    if (calle.isNotEmpty) {
      partes.add(numero.isNotEmpty ? '$calle $numero' : calle);
    }
    if (distrito.isNotEmpty) partes.add(distrito);
    if (ciudad.isNotEmpty && ciudad != distrito) partes.add(ciudad);
    if (region.isNotEmpty) partes.add(region);
    if (pais.isNotEmpty) partes.add(pais);
    return partes.join(', ');
  }

  @override
  String toString() => hasData ? direccionCompleta : 'Sin ubicación: $error';
}

// ── MODELO DE RESPUESTA ──────────────────────────────────────
// Resultado de getCoordinates() — con manejo de errores limpio
class CoordinatesResult {
  final double? latitud;
  final double? longitud;
  final double? altitud;
  final double? precision;
  final String error;
  final bool hasLocation;

  const CoordinatesResult({
    this.latitud,
    this.longitud,
    this.altitud,
    this.precision,
    this.error = '',
    this.hasLocation = false,
  });

  /// Latitud y longitud como string combinado: "-12.0464,-77.0428"
  String get coordsString => hasLocation ? '$latitud,$longitud' : '0.0,0.0';

  @override
  String toString() => hasLocation
      ? 'Lat: $latitud, Lon: $longitud (±${precision?.toStringAsFixed(0)}m)'
      : 'Sin ubicación: $error';
}

// ── MODELO DE TIPO DE CONEXIÓN ───────────────────────────────
enum TipoConexion { wifi, mobile, ethernet, ninguna, desconocida }

// ── SERVICIO PRINCIPAL ───────────────────────────────────────
class DeviceInfoService {
  // Singletons internos — se crean una vez, no se instancian de nuevo
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final NetworkInfo _networkInfo = NetworkInfo();
  CoordinatesResult? _cachedCoords;

  // ── CACHE ESTÁTICO — compartido entre todas las instancias ──
  static Future<Map<String, String>>? _backgroundFuture;
  static Map<String, String>? _cachedInfo;

  static void precargarEnBackground() {
    _backgroundFuture ??= DeviceInfoService()._cargarTodoInterno();
  }

  static Future<Map<String, String>> getInfoConTimeout() async {
    // Ya tenemos el resultado completo — instantáneo
    if (_cachedInfo != null) return _cachedInfo!;

    // Si por alguna razón no se llamó precargarEnBackground, lo lanzamos ahora
    _backgroundFuture ??= DeviceInfoService()._cargarTodoInterno();

    try {
      _cachedInfo = await _backgroundFuture!.timeout(
        const Duration(seconds: 3),
      );
      return _cachedInfo!;
    } catch (_) {
      // Timeout o error — retorna valores por defecto para no bloquear el login
      return _defaultInfo();
    }
  }

  /// Valores por defecto si el GPS no respondió a tiempo
  static Map<String, String> _defaultInfo() => {
    'ip_local': '0.0.0.0',
    'so_version': 'Desconocido',
    'modelo': 'Desconocido',
    'tipo_dispositivo': 'Mobile',
    'so': 'Android',
    'es_fisico': 'true',
    'coordenadas': '0.0,0.0',
    'pais': '',
    'pais_codigo': 'PE',
    'region': '',
    'provincia': '',
    'ciudad': '',
    'navegador': 'Flutter App',
  };

  /// Método interno — lo llama precargarEnBackground()
  Future<Map<String, String>> _cargarTodoInterno() async {
    // Resuelve GPS una sola vez antes del Future.wait
    await getCoordinates();

    final results = await Future.wait([
      getLocalIp(),
      getVersionSO(),
      getDeviceModel(),
      getTipoDispositivo(),
      getSistemaOperativo(),
      getCoordenadasString(),
      getUbicacionCompleta(),
    ]);

    final esFisico = (await esDispositivoFisico()).toString();
    final ubic = results[6] as UbicacionResult;

    return {
      'ip_local': results[0] as String,
      'so_version': results[1] as String,
      'modelo': results[2] as String,
      'tipo_dispositivo': results[3] as String,
      'so': results[4] as String,
      'es_fisico': esFisico,
      'coordenadas': results[5] as String,
      'pais': ubic.pais,
      'pais_codigo': ubic.paisCodigo.isNotEmpty ? ubic.paisCodigo : 'PE',
      'region': ubic.region,
      'provincia': ubic.provincia,
      'ciudad': ubic.ciudad,
      'navegador': 'Flutter App',
    };
  }

  // ============================================================
  // ① RED — IP y CONECTIVIDAD
  // ============================================================

  /// IP local del dispositivo en la red WiFi/LAN.
  /// Retorna '0.0.0.0' si no está conectado o no tiene WiFi.
  ///
  /// Ejemplo: '192.168.1.10'
  Future<String> getLocalIp() async {
    try {
      final ip = await _networkInfo.getWifiIP();
      return ip ?? '0.0.0.0';
    } catch (_) {
      return '0.0.0.0';
    }
  }

  // ============================================================
  // ② UBICACIÓN — GPS
  // ============================================================

  Future<bool> solicitarPermisoUbicacion() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  Future<CoordinatesResult> getCoordinates() async {
    // ✅ Si ya lo obtuvimos, retorna el cache
    if (_cachedCoords != null) return _cachedCoords!;

    try {
      final tienePermiso = await solicitarPermisoUbicacion();
      if (!tienePermiso) {
        _cachedCoords = const CoordinatesResult(
          error: 'Permiso de ubicación denegado',
        );
        return _cachedCoords!;
      }

      // ✅ Double timeout: LocationSettings + .timeout() como respaldo
      final position =
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 10),
            ),
          ).timeout(
            const Duration(seconds: 12), // margen extra
            onTimeout: () => throw TimeoutException('GPS timeout'),
          );

      _cachedCoords = CoordinatesResult(
        latitud: position.latitude,
        longitud: position.longitude,
        altitud: position.altitude,
        precision: position.accuracy,
        hasLocation: true,
      );
      return _cachedCoords!;
    } on LocationServiceDisabledException {
      _cachedCoords = const CoordinatesResult(
        error: 'GPS desactivado en el dispositivo',
      );
      return _cachedCoords!;
    } on TimeoutException {
      _cachedCoords = const CoordinatesResult(
        error: 'Tiempo de espera agotado para obtener GPS',
      );
      return _cachedCoords!;
    } catch (e) {
      _cachedCoords = CoordinatesResult(error: e.toString());
      return _cachedCoords!;
    }
  }

  /// Coordenadas como string combinado: "latitud,longitud"
  /// Ejemplo: '-12.0464,-77.0428'
  Future<String> getCoordenadasString() async {
    final coords = await getCoordinates();
    return coords.coordsString;
  }

  // ============================================================
  // ③ DISPOSITIVO — Hardware y SO
  // ============================================================

  Future<String> getDeviceModel() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return '${info.manufacturer} ${info.model}';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.utsname.machine;
      }
      return 'Desconocido';
    } catch (_) {
      return 'Desconocido';
    }
  }

  /// Tipo de dispositivo: 'Mobile', 'Tablet', 'Desktop'.
  Future<String> getTipoDispositivo() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        // Una heurística simple: si tiene "tablet" en el nombre, es tablet
        final model = info.model.toLowerCase();
        if (model.contains('tablet') || model.contains('tab')) return 'Tablet';
        return 'Mobile';
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.model.toLowerCase().contains('ipad') ? 'Tablet' : 'Mobile';
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 'Desktop';
      }
      return 'Mobile';
    } catch (_) {
      return 'Mobile';
    }
  }

  /// Sistema operativo como string.
  /// Ejemplo: 'Android' o 'iOS'
  Future<String> getSistemaOperativo() async {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    return 'Desconocido';
  }

  /// Versión del sistema operativo.
  ///
  /// Android → 'Android 13' (API 33)
  /// iOS     → 'iOS 17.2'
  Future<String> getVersionSO() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return 'Android ${info.version.release}'; // 'Android 13'
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return 'iOS ${info.systemVersion}'; // 'iOS 17.2'
      }
      return Platform.operatingSystem;
    } catch (_) {
      return 'Desconocido';
    }
  }

  /// true si el build es físico (no emulador).
  Future<bool> esDispositivoFisico() async {
    try {
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;
        return info.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;
        return info.isPhysicalDevice;
      }
      return true;
    } catch (_) {
      return true;
    }
  }

  // ============================================================
  // ⑤ GEOCODIFICACIÓN INVERSA — Dirección desde coordenadas GPS
  // ============================================================

  Future<UbicacionResult> getUbicacionCompleta() async {
    try {
      final coords = await getCoordinates(); // ✅ usa el cache
      if (!coords.hasLocation) {
        return UbicacionResult(error: coords.error);
      }

      // ✅ Timeout en geocodificación inversa
      final placemarks =
          await placemarkFromCoordinates(
            coords.latitud!,
            coords.longitud!,
          ).timeout(
            const Duration(seconds: 8),
            onTimeout: () => [], // retorna lista vacía en vez de colgarse
          );

      if (placemarks.isEmpty) {
        return const UbicacionResult(
          error: 'No se encontró dirección para estas coordenadas',
        );
      }

      final place = placemarks.first;
      return UbicacionResult(
        pais: place.country ?? '',
        paisCodigo: place.isoCountryCode ?? '',
        region: place.administrativeArea ?? '',
        provincia: place.subAdministrativeArea ?? '',
        ciudad: place.locality ?? '',
        distrito: place.subLocality?.isNotEmpty == true
            ? place.subLocality!
            : (place.locality ?? ''),
        subLocality: place.subLocality ?? '',
        calle: place.thoroughfare ?? '',
        numero: place.subThoroughfare ?? '',
        codigoPostal: place.postalCode ?? '',
        hasData: true,
      );
    } catch (e) {
      return UbicacionResult(error: e.toString());
    }
  }

  // ============================================================
  // ⑥ Todo junto — El método estrella
  // ============================================================

  Future<Map<String, String>> getAllDeviceInfo() async {
    // Ejecutar en paralelo — mucho más rápido que await uno por uno
    final results = await Future.wait([
      getLocalIp(),
      getVersionSO(),
      getDeviceModel(),
      getTipoDispositivo(),
      getSistemaOperativo(),
      getCoordenadasString(), // ✅ usa cache
      getUbicacionCompleta(), // ✅ usa cache
    ]);

    final esFisico = (await esDispositivoFisico()).toString();
    // Extraer el resultado de geocodificación
    final ubic = results[6] as UbicacionResult;

    return {
      // ── Red ───────────────────────────────
      'ip_local': results[0] as String,
      // 'ip_publica':        results[1] as String,
      // 'wifi_nombre':       results[2] ?? '',
      // 'tipo_conexion':     tipoConex,

      // ── SO / Hardware ─────────────────────
      'so_version': results[1] as String, // 'Android 13'
      'modelo': results[2] as String, // 'samsung SM-G991B'
      'tipo_dispositivo': results[3] as String, // 'Mobile'
      'so': results[4] as String, // 'Android'
      'es_fisico': esFisico, // 'true'
      // ── Ubicación ─────────────────────────
      'coordenadas': results[5] as String, // '-12.0464,-77.0428'
      // ── Dirección real desde GPS ──────────
      'pais': ubic.pais, // 'Perú'
      'pais_codigo': ubic.paisCodigo.isNotEmpty ? ubic.paisCodigo : 'PE',
      'region': ubic.region, // 'Lima'
      'provincia': ubic.provincia, // 'Lima Province'
      'ciudad': ubic.ciudad, // 'Lima'
      // ── Valores fijos para la API ──────────
      // (estos los espera tu API actual — ajusta según necesites)
      'navegador': 'Flutter App',
    };
  }

  // ============================================================
  // ⑦ HELPER — Construir el body del Login directamente
  // ============================================================

  Future<String> buildLoginBody({
    required String username,
    required String password,
  }) async {
    // ✅ Usa el cache estático — no bloquea el login
    final info = await DeviceInfoService.getInfoConTimeout();

    return 'PER'
        '¦$username'
        '¦$password'
        '¦${info['ip_local']}'
        '¦${info['coordenadas']}'
        '¦${info['so']}'
        '¦${info['modelo']}'
        '¦${info['so_version']}'
        '¦${info['pais_codigo']}'
        '¦${info['region']}'
        '¦${info['ciudad']}'
        '¦${AppConstants.version}';
  }
}
