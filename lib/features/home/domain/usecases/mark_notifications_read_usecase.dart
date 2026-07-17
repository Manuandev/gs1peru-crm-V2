// lib/features/home/domain/usecases/mark_notifications_read_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/home/index_home.dart';

class MarkNotificationsReadUseCase {
  final HomeRepository repository;
  const MarkNotificationsReadUseCase(this.repository);

  Future<CrudResult> call() => repository.marcarNotificacionesLeidas();
}
