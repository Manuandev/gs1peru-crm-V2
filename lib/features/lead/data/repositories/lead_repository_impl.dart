// lib\features\lead\data\repositories\lead_repository_impl.dart

import 'package:app_crm/features/lead/index_lead.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDatasource _remote;

  LeadRepositoryImpl(this._remote);

  @override
  Future<List<ProspectoModel>> getProspectos() => _remote.getProspectos();

  @override
  Future<List<PropuestaModel>> getPropuestas() => _remote.getPropuestas();
}
