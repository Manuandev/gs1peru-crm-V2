// lib/features/solicitudes/data/repositories/solicitud_repository_impl.dart

import 'package:app_crm/features/solicitudes/data/datasources/remote/solicitud_remote_datasource.dart';
import 'package:app_crm/features/solicitudes/data/models/solicitud_model.dart';
import 'package:app_crm/features/solicitudes/domain/repositories/solicitud_repository.dart';

class SolicitudRepositoryImpl implements SolicitudRepository {
  final SolicitudRemoteDatasource _remote;

  SolicitudRepositoryImpl(this._remote);

  @override
  Future<List<SolicitudModel>> getSolicitudes() => _remote.getSolicitudes();
}
