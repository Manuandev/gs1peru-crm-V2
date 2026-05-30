// lib\features\home\presentation\bloc\notifications\notifications_event.dart

import 'package:app_crm/index_dependencies.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class NotificationStarted extends NotificationEvent {
  const NotificationStarted();
}

class NotificationRefresh extends NotificationEvent {
  const NotificationRefresh();
}
