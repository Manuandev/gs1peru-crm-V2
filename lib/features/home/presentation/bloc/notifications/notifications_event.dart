// lib/features/home/presentation/bloc/notifications/notifications_event.dart

import 'package:app_crm/index_dependencies.dart';

import 'package:app_crm/features/home/index_home.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class NotificationsStarted extends NotificationsEvent {
  const NotificationsStarted();
}

class NotificationsRefresh extends NotificationsEvent {
  const NotificationsRefresh();
}

/// Cambio de chip. Con paginación el filtro va al SP, así que recarga desde
/// la primera página en vez de filtrar la lista en memoria.
class NotificationsFiltroCambiado extends NotificationsEvent {
  final FiltroNotificacion filtro;
  const NotificationsFiltroCambiado(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// El scroll llegó al final — pide la página siguiente.
class NotificationsPaginaSolicitada extends NotificationsEvent {
  const NotificationsPaginaSolicitada();
}

/// Reintentar la página que falló (botón en el footer de la lista).
class NotificationsReintentarPagina extends NotificationsEvent {
  const NotificationsReintentarPagina();
}
