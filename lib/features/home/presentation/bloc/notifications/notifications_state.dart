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

  List<Notificacion> get actividades => notificaciones
      .where((n) => n.tipo == TipoNotificacion.actividad)
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
