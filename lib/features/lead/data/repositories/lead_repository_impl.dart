// lib/features/lead/data/repositories/lead_repository_impl.dart

import 'package:app_crm/features/lead/index_lead.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDatasource _remote;

  LeadRepositoryImpl(this._remote);

  @override
  Future<List<LeadModel>> getLeads(String proceso) => _remote.getLeads(proceso);
  
  @override
  Future<LeadDetalleModel> getLeadDetalle(int idLead) => _remote.getLeadDetalle(idLead);

  @override
  Future<void> toggleFavorito(int idLead, bool isFavorito) =>
      _remote.marcarFavorito(idLead, isFavorito);
}
