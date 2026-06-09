// lib/core/notifications/services/notification_permission_manager.dart

import 'package:app_crm/core/index_core.dart';

/// Gestiona cuándo y cómo solicitar permisos de notificación.
/// Persiste el estado en LocalDatabase para no spamear al usuario.
class NotificationPermissionManager {
  NotificationPermissionManager._();
  static final NotificationPermissionManager instance =
      NotificationPermissionManager._();

  static const _claveEstado = 'notif_permiso_estado';
  static const _claveUltimaSolicitud = 'notif_ultima_solicitud';

  // Días mínimos entre re-solicitudes cuando el usuario ignoró el diálogo
  static const _diasEntreReSolicitudes = 3;

  final _db = LocalDatabase();

  /// Determina si se debe mostrar el diálogo de permisos.
  ///
  /// No solicita si:
  /// - El permiso ya fue concedido (no molestar de nuevo)
  /// - El usuario denegó explícitamente (no ignoró, rechazó)
  /// - El usuario ignoró el diálogo hace menos de [_diasEntreReSolicitudes] días
  Future<bool> deberiaSolicitar() async {
    final estado = await _db.getSetting(_claveEstado);

    if (estado == EstadoPermiso.concedido) return false;
    if (estado == EstadoPermiso.denegado) return false;

    if (estado == EstadoPermiso.ignorado) {
      final ultimaStr = await _db.getSetting(_claveUltimaSolicitud);
      if (ultimaStr != null) {
        final ultima = DateTime.tryParse(ultimaStr);
        if (ultima != null) {
          final diasTranscurridos = DateTime.now().difference(ultima).inDays;
          if (diasTranscurridos < _diasEntreReSolicitudes) return false;
        }
      }
    }

    // Primera vez o ignorado hace más de N días → solicitar
    return true;
  }

  Future<void> guardarConcedido() => _guardarEstado(EstadoPermiso.concedido);

  Future<void> guardarDenegado() => _guardarEstado(EstadoPermiso.denegado);

  /// Ignorado = el usuario no respondió (timeout) o cerró la app con el diálogo abierto.
  /// Se vuelve a solicitar después de [_diasEntreReSolicitudes] días.
  Future<void> guardarIgnorado() => _guardarEstado(EstadoPermiso.ignorado);

  Future<bool> get esConcedido async =>
      (await _db.getSetting(_claveEstado)) == EstadoPermiso.concedido;

  Future<void> _guardarEstado(String estado) async {
    await _db.setSetting(_claveEstado, estado);
    await _db.setSetting(
      _claveUltimaSolicitud,
      DateTime.now().toIso8601String(),
    );
  }
}

/// Posibles estados del permiso de notificación.
abstract final class EstadoPermiso {
  static const concedido = 'concedido';
  static const denegado = 'denegado';

  /// El usuario no respondió al diálogo (timeout) o fue descartado sin elegir.
  static const ignorado = 'ignorado';
}
