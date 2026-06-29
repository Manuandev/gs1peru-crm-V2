// lib/features/lead/data/repositories/lead_repository_impl.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDatasource _remote;
  final _contactoRemote = ContactoDetalleRemoteDatasource();

  LeadRepositoryImpl(this._remote);

  @override
  Future<List<LeadModel>> getLeads() => _remote.getLeads();

  @override
  Future<LeadDetalleModel> getLeadDetalle(int idLead) =>
      _remote.getLeadDetalle(idLead);

  @override
  Future<void> toggleFavorito(int idLead, bool isFavorito) =>
      _remote.marcarFavorito(idLead, isFavorito);

  @override
  Future<CrudResult> updateLeadCompleto(Lead lead) =>
      _remote.updateLeadCompleto(lead);

  @override
  Future<ContactoDetalleModel> obtenerDetalleContacto(int idContacto) =>
      _contactoRemote.obtenerDetalleContacto(idContacto);

  @override
  Future<List<NegociacionModel>> obtenerNegociaciones(int idLead) =>
      _remote.getLeadNegociaciones(idLead);
}
