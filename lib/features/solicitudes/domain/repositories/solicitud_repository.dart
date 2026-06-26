// lib/features/solicitudes/domain/repositories/solicitud_repository.dart

import 'package:app_crm/features/solicitudes/domain/entities/solicitud.dart';

abstract class SolicitudRepository {
  Future<List<Solicitud>> getSolicitudes();
}
