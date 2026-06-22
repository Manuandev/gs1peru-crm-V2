// lib/core/services/location_permission_manager.dart

import 'package:app_crm/core/index_core.dart';

/// Gestiona cuándo y cómo solicitar el permiso de ubicación.
/// Persiste el estado en LocalDatabase para no repetir solicitudes al usuario.
/// Mismo patrón que NotificationPermissionManager.
class LocationPermissionManager {
  LocationPermissionManager._();
  static final LocationPermissionManager instance =
      LocationPermissionManager._();

  static const _claveEstado = 'ubicacion_permiso_estado';
  static const _claveUltimaSolicitud = 'ubicacion_ultima_solicitud';
  static const _diasEntreReSolicitudes = 3;

  final _db = LocalDatabase();

  /// false si: ya concedido, denegado permanentemente, o denegado hace < N días.
  /// true en cualquier otro caso (primera vez, o denegado hace ya suficiente tiempo).
  Future<bool> deberiaSolicitar() async {
    final estado = await _db.getSetting(_claveEstado);

    if (estado == _EstadoUbicacion.concedido) return false;
    if (estado == _EstadoUbicacion.denegadoPermanente) return false;

    if (estado == _EstadoUbicacion.denegado) {
      final ultimaStr = await _db.getSetting(_claveUltimaSolicitud);
      if (ultimaStr != null) {
        final ultima = DateTime.tryParse(ultimaStr);
        if (ultima != null &&
            DateTime.now().difference(ultima).inDays <
                _diasEntreReSolicitudes) {
          return false;
        }
      }
    }

    return true;
  }

  Future<void> guardarConcedido() =>
      _guardarEstado(_EstadoUbicacion.concedido);

  /// Denegado simple: el OS todavía permite volver a solicitar más adelante.
  Future<void> guardarDenegado() => _guardarEstado(_EstadoUbicacion.denegado);

  /// Denegado permanente: el usuario eligió "No preguntar de nuevo".
  /// Nunca se vuelve a solicitar — el usuario debe ir a Configuración del sistema.
  Future<void> guardarDenegadoPermanente() =>
      _guardarEstado(_EstadoUbicacion.denegadoPermanente);

  Future<void> _guardarEstado(String estado) async {
    await _db.setSetting(_claveEstado, estado);
    await _db.setSetting(
      _claveUltimaSolicitud,
      DateTime.now().toIso8601String(),
    );
  }
}

abstract final class _EstadoUbicacion {
  static const concedido = 'concedido';
  static const denegado = 'denegado';
  static const denegadoPermanente = 'denegado_permanente';
}
