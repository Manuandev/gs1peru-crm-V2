// lib/features/home/domain/entities/notifications/notification.dart

import 'package:app_crm/features/home/domain/entities/notifications/notificacion.dart';

class Notification {
  final int totNotificaciones;
  final int totActividades;
  final int totDerivaciones;
  final int totMensajes;
  final List<Notificacion> notificaciones;

  const Notification({
    required this.totNotificaciones,
    required this.totActividades,
    required this.totDerivaciones,
    required this.totMensajes,
    required this.notificaciones,
  });
}
