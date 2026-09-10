// lib/features/home/domain/usecases/get_notifications_usecase.dart

import 'package:app_crm/features/home/index_home.dart';

class GetNotificationsUseCase {
  final HomeRepository repository;
  const GetNotificationsUseCase(this.repository);

  Future<NotificacionesPagina> call({
    FiltroNotificacion filtro = FiltroNotificacion.todas,
    String? cursorFecha,
    int? cursorId,
    required int tamanio,
  }) => repository.getNotifications(
    filtro: filtro,
    cursorFecha: cursorFecha,
    cursorId: cursorId,
    tamanio: tamanio,
  );
}
