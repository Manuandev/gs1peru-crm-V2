// lib\features\home\domain\usecases\get_notifications_usecase.dart

import 'package:app_crm/features/home/index_home.dart';

class GetNotificationUseCase {
  final HomeRepository repository;
  const GetNotificationUseCase(this.repository);

  Future<List<Notification>> call() => repository.getNotifications();
}
