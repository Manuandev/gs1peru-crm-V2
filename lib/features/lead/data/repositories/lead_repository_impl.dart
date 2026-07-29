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

  @override
  Future<ContactoDetalleModel> getContactoPorIdNumero(int idNumero) =>
      _remote.getContactoPorIdNumero(idNumero);

  @override
  Future<CrudResult> guardarContacto(ContactoDetalle contacto) =>
      _remote.guardarContacto(contacto);

  @override
  Future<ContactoSimpleModel> getContactoSimplePorIdNumero(int idNumero) =>
      _remote.getContactoSimplePorIdNumero(idNumero);

  @override
  Future<CrudResult> guardarContactoSimple(ContactoSimple contacto) =>
      _remote.guardarContactoSimple(contacto);
}
