// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:app_crm/features/home/index_home.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource _remote;

  HomeRepositoryImpl(this._remote);

  @override
  Future<Home> getData() => _remote.getData();

  @override
  Future<Notification> getNotifications() => _remote.getNotifications();
}
