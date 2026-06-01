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
  final Notification notification;

  const NotificationsLoaded({required this.notification});
  
  int get totNotificaciones => notification.totNotificaciones;
  int get totLeadsReasignados => notification.totLeadsReasignados;
  int get totLeadsNuevos => notification.totLeadsNuevos;
  int get totRecordatorios => notification.totRecordatorios;
  List<LeadReasignado> get leadsReasignados => notification.leadsReasignados;
  List<LeadNuevo> get leadsNuevos => notification.leadsNuevos;
  List<Recordatorio> get recordatorios => notification.recordatorios;
  
  @override
  List<Object?> get props => [notification];
}

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
