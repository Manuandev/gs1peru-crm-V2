// lib/features/home/data/repositories/home_repository_impl.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource _remote;

  HomeRepositoryImpl(this._remote);

  @override
  Future<Home> getData() => _remote.getData();

  @override
  Future<List<Notificacion>> getNotifications() => _remote.getNotifications();

  @override
  Future<CrudResult> marcarNotificacionesLeidas() =>
      _remote.marcarNotificacionesLeidas();

  @override
  Future<CrudResult> gestionarPrioridad(int idNumero) =>
      _remote.gestionarPrioridad(idNumero);
}
