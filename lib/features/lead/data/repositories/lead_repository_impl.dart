// lib/features/lead/data/repositories/lead_repository_impl.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class LeadRepositoryImpl implements LeadRepository {
  final LeadRemoteDatasource _remote;

  LeadRepositoryImpl(this._remote);

  @override
  Future<List<ContactoNegociacionModel>> getLeads() => _remote.getLeads();

  @override
  Future<NegociacionModel> getLeadDetalle(int idLead) =>
      _remote.getLeadDetalle(idLead);

  @override
  Future<NegociacionModel> getLeadDetallePorNumero(int idNumero) =>
      _remote.getLeadDetallePorNumero(idNumero);

  @override
  Future<CrudResult> updateNegociacion(Negociacion negociacion, int idNumero) =>
      _remote.updateNegociacion(negociacion, idNumero);

  @override
  Future<List<NegociacionModel>> obtenerNegociaciones(int idNumero) =>
      _remote.obtenerNegociaciones(idNumero);

  @override
  Future<List<HistorialComentarioModel>> obtenerHistorialSeguimientoPorNumero(
    int idNumero,
  ) => _remote.obtenerHistorialSeguimientoPorNumero(idNumero);
}
