// lib/core/services/device_info_service.dart
// ============================================================
// DEVICE INFO SERVICE
// ============================================================
//
// RESPONSABILIDAD:
// Obtener información del dispositivo en tiempo real.
// Cada getter llama directo al hardware/SO — sin caché.
//
// DEPENDENCIAS (agregar en pubspec.yaml):
//   device_info_plus: ^10.1.2
//   geolocator: ^13.0.4
//   network_info_plus: ^6.1.1
//   package_info_plus: ^8.3.0
//   connectivity_plus: ^6.1.4
//
// PERMISOS (agregar según plataforma):
//
// Android → android/app/src/main/AndroidManifest.xml:
//   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
//   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
//   <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
//
// iOS → ios/Runner/Info.plist:
//   <key>NSLocationWhenInUseUsageDescription</key>
//   <string>Necesitamos tu ubicación para registrar tu acceso.</string>
//
// USO BÁSICO:
//   final service = DeviceInfoService();
//
//   // Individual — en tiempo real
//   final ip     = await service.getLocalIp();
//   final coords = await service.getCoordinates();
//   final model  = await service.getDeviceModel();
//
//   // Todo junto — para el body del login u otra petición
//   final info = await service.getAllDeviceInfo();
//   print(info['ip_local']);       // 192.168.1.10
//   print(info['latitud']);        // -12.0464
//   print(info['longitud']);       // -77.0428
//   print(info['modelo']);         // Samsung Galaxy S23
//   print(info['so_version']);     // Android 13
//   print(info['app_version']);    // 1.0.0+1
//
// ============================================================

import 'dart:async';
import 'dart:io';
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

  /// Solicita permiso de ubicación si no fue otorgado.
  /// Retorna true si el permiso fue concedido o ya estaba activo.
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

  /// Coordenadas GPS actuales del dispositivo.
  /// Maneja permisos denegados y GPS apagado automáticamente.
  ///
  /// Retorna CoordinatesResult — siempre seguro, nunca lanza excepción.
  ///
  /// Ejemplo:
  ///   final coords = await service.getCoordinates();
  ///   print(coords.latitud);       // -12.0464
  ///   print(coords.longitud);      // -77.0428
  ///   print(coords.hasLocation);   // true
  Future<CoordinatesResult> getCoordinates() async {
    try {
      final tienePermiso = await solicitarPermisoUbicacion();
      if (!tienePermiso) {
        return const CoordinatesResult(error: 'Permiso de ubicación denegado');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return CoordinatesResult(
        latitud: position.latitude,
        longitud: position.longitude,
        altitud: position.altitude,
        precision: position.accuracy,
        hasLocation: true,
      );
    } on LocationServiceDisabledException {
      return const CoordinatesResult(
        error: 'GPS desactivado en el dispositivo',
      );
    } on TimeoutException {
      return const CoordinatesResult(
        error: 'Tiempo de espera agotado para obtener GPS',
      );
    } catch (e) {
      return CoordinatesResult(error: e.toString());
    }
  }

  /// Latitud como String. Retorna '0.0' si no hay permiso o GPS.
  Future<String> getLatitud() async {
    final coords = await getCoordinates();
    return coords.latitud?.toString() ?? '0.0';
  }

  /// Longitud como String. Retorna '0.0' si no hay permiso o GPS.
  Future<String> getLongitud() async {
    final coords = await getCoordinates();
    return coords.longitud?.toString() ?? '0.0';
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

  /// Modelo del dispositivo.
  ///
  /// Android → 'samsung SM-G991B'
  /// iOS     → 'iPhone 15 Pro'
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

  /// Obtiene la dirección completa del dispositivo a partir de sus
  /// coordenadas GPS. Incluye país, región, provincia, ciudad,
  /// distrito, calle, número y código postal.
  ///
  /// REQUIERE: permiso de ubicación + paquete geocoding.
  ///
  /// Ejemplo de resultado:
  ///   ubicacion.pais         → 'Perú'
  ///   ubicacion.paisCodigo   → 'PE'
  ///   ubicacion.region       → 'Lima'
  ///   ubicacion.provincia    → 'Lima Province'
  ///   ubicacion.ciudad       → 'Lima'
  ///   ubicacion.distrito     → 'Miraflores'
  ///   ubicacion.calle        → 'Av. Larco'
  ///   ubicacion.numero       → '345'
  ///   ubicacion.codigoPostal → '15074'
  ///   ubicacion.direccionCompleta → 'Av. Larco 345, Miraflores, Lima, Perú'
  Future<UbicacionResult> getUbicacionCompleta() async {
    try {
      // 1. Obtener coordenadas GPS
      final coords = await getCoordinates();
      if (!coords.hasLocation) {
        return UbicacionResult(error: coords.error);
      }

      // 2. Geocodificación inversa: coordenadas → lista de Placemark
      final placemarks = await placemarkFromCoordinates(
        coords.latitud!,
        coords.longitud!,
      );

      if (placemarks.isEmpty) {
        return const UbicacionResult(
          error: 'No se encontró dirección para estas coordenadas',
        );
      }

      // El primer Placemark es el más preciso
      final place = placemarks.first;

      return UbicacionResult(
        // País
        pais: place.country ?? '',
        paisCodigo: place.isoCountryCode ?? '',

        // División administrativa
        // administrativeArea   → departamento/estado: 'Lima'
        // subAdministrativeArea → provincia: 'Lima Province'
        // locality             → ciudad/distrito: 'Miraflores'
        // subLocality          → barrio/urbanización
        region: place.administrativeArea ?? '',
        provincia: place.subAdministrativeArea ?? '',
        ciudad: place.locality ?? '',
        distrito: place.subLocality?.isNotEmpty == true
            ? place.subLocality!
            : (place.locality ?? ''),
        subLocality: place.subLocality ?? '',

        // Calle y número
        calle: place.thoroughfare ?? '',
        numero: place.subThoroughfare ?? '',

        // Código postal
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

  /// Obtiene TODA la información del dispositivo en un solo Map.
  ///
  /// Hace todas las llamadas en paralelo (Future.wait) para ser
  /// lo más rápido posible. Ideal para el body del login o
  /// cualquier petición que necesite datos del dispositivo.
  ///
  // ignore: unintended_html_in_doc_comment
  /// Retorna un Map<String, String> con todas las claves.
  ///
  /// EJEMPLO DE USO:
  /// ```dart
  /// final info = await DeviceInfoService().getAllDeviceInfo();
  ///
  /// final body = 'PER¦$user¦$pass'
  ///   '¦${info['ip_local']}'
  ///   '¦${info['coordenadas']}'
  ///   '¦${info['navegador']}'
  ///   '¦${info['tipo_dispositivo']}'
  ///   '¦${info['dispositivo']}'
  ///   '¦${info['pais_codigo']}'
  ///   '¦${info['region']}'
  ///   '¦${info['ciudad']}'
  ///   '¦${info['so_version']}';
  /// ```
  Future<Map<String, String>> getAllDeviceInfo() async {
    // Ejecutar en paralelo — mucho más rápido que await uno por uno
    final results = await Future.wait([
      getLocalIp(), // [0]
      getVersionSO(), // [1]
      getDeviceModel(), // [2]
      getTipoDispositivo(), // [3]
      getSistemaOperativo(), // [4]
      getCoordenadasString(), // [5]
      getUbicacionCompleta(), // [6]
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

  /// Construye el body en el formato de tu API:
  /// "PER¦{user}¦{pass}¦{ip}¦{lat,lon}¦{navegador}¦{tipo}¦{dispositivo}¦{pais}¦{region}¦{ciudad}¦{so}"
  ///
  /// Reemplaza los valores hardcodeados del auth_remote_datasource.dart.
  ///
  /// EJEMPLO:
  /// ```dart
  /// final body = await DeviceInfoService().buildLoginBody(
  ///   username: 'JPEREZ',
  ///   password: 'mi_clave',
  /// );
  /// // body = "PER¦JPEREZ¦mi_clave¦192.168.1.10¦-12.0464,-77.0428¦Flutter App¦Mobile¦SM-G991B¦PE¦Lima Province¦Lima¦Android 13"
  /// ```
  Future<String> buildLoginBody({
    required String username,
    required String password,
  }) async {
    final info = await getAllDeviceInfo();

    return 'PER'
        '¦$username'
        '¦$password'
        '¦${info['ip_local']}'
        '¦${info['coordenadas']}'
        '¦${info['navegador']}'
        '¦${info['tipo_dispositivo']}'
        '¦${info['modelo']}'
        '¦${info['pais_codigo']}'
        '¦${info['region']}'
        '¦${info['ciudad']}'
        '¦${info['so_version']}';
  }
}
