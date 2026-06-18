// lib/features/lead/data/repositories/lead_repository_impl.dart

import 'package:app_crm/features/lead/index_lead.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDatasource _remote;
  // TODO: reemplazar por inyección cuando se defina el SP real de contactos
  final _contactoRemote = ContactoDetalleRemoteDatasource();

  LeadRepositoryImpl(this._remote);

  @override
  Future<List<LeadModel>> getLeads(String proceso) => _remote.getLeads(proceso);

  @override
  Future<LeadDetalleModel> getLeadDetalle(int idLead) =>
      _remote.getLeadDetalle(idLead);

  @override
  Future<void> toggleFavorito(int idLead, bool isFavorito) =>
      _remote.marcarFavorito(idLead, isFavorito);

  @override
  Future<ContactoDetalleModel> obtenerDetalleContacto(int idContacto) =>
      _contactoRemote.obtenerDetalleContacto(idContacto);

  @override
  Future<List<LeadModel>> obtenerNegociacionesDeContacto(int idContacto) =>
      _contactoRemote.obtenerNegociacionesDeContacto(idContacto);
}
