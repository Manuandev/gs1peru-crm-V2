// lib\features\home\domain\repositories\home_repository.dart

import 'package:app_crm/features/home/index_home.dart';

abstract class HomeRepository {
  Future<Home> getData();

  Future<Notification> getNotifications();
}
