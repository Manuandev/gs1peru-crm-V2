// lib/features/home/presentation/bloc/notifications/notifications_event.dart

import 'package:app_crm/index_dependencies.dart';

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
