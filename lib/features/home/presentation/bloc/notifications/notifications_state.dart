// lib/features/home/presentation/bloc/notifications/notifications_state.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/home/index_home.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  final List<Notificacion> notificationes;

  const NotificationsLoaded({required this.notificationes});

  List<Notificacion> get notificaciones => notificationes;

  // Chip "Actividades" agrupa todo lo que no es derivación (bot) ni mensaje:
  // recordatorios, leads por contactar, leads reasignados y la actividad
  // genérica (códigos sin tipo dedicado, ej. GESTION_DE_CODIGO) — pedido de
  // negocio 2026-08-24, ver home/CLAUDE.md.
  List<Notificacion> get actividades => notificaciones
      .where(
        (n) =>
            n.tipo == TipoNotificacion.actividad ||
            n.tipo == TipoNotificacion.recordatorio ||
            n.tipo == TipoNotificacion.leadPorContactar ||
            n.tipo == TipoNotificacion.leadReasignado,
      )
      .toList();

  List<Notificacion> get derivaciones => notificaciones
      .where((n) => n.tipo == TipoNotificacion.derivacion)
      .toList();

  List<Notificacion> get mensajes =>
      notificaciones.where((n) => n.tipo == TipoNotificacion.mensaje).toList();

  @override
  List<Object?> get props => [notificationes];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
