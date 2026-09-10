// lib/features/home/domain/repositories/home_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

abstract class HomeRepository {
  Future<Home> getData();

  Future<NotificacionesPagina> getNotifications({
    FiltroNotificacion filtro,
    String? cursorFecha,
    int? cursorId,
    required int tamanio,
  });

  Future<CrudResult> marcarNotificacionesLeidas();

  Future<CrudResult> gestionarPrioridad(int idNumero);
}
