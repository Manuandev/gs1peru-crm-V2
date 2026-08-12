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
  Future<DatosPrellenadoSolicitudModel> getDatosPrellenadoSolicitud(
    int idLead,
  ) => _remote.getDatosPrellenadoSolicitud(idLead);

  @override
  Future<NegociacionModel> getLeadDetallePorContacto(int idContacto) =>
      _remote.getLeadDetallePorContacto(idContacto);

  @override
  Future<CrudResult> updateNegociacion(
    Negociacion negociacion,
    int idContacto,
  ) => _remote.updateNegociacion(negociacion, idContacto);

  @override
  Future<List<NegociacionModel>> obtenerNegociaciones(int idContacto) =>
      _remote.obtenerNegociaciones(idContacto);

  @override
  Future<List<HistorialComentarioModel>> obtenerHistorialSeguimientoPorContacto(
    int idContacto,
  ) => _remote.obtenerHistorialSeguimientoPorContacto(idContacto);

  @override
  Future<List<LeadRecordatorioModel>> obtenerRecordatoriosPorContacto(
    int idContacto,
  ) => _remote.obtenerRecordatoriosPorContacto(idContacto);

  @override
  Future<ContactoDetalleModel> getContactoPorIdNumero(int idNumero) =>
      _remote.getContactoPorIdNumero(idNumero);

  @override
  Future<CrudResult> guardarContacto(ContactoDetalle contacto) =>
      _remote.guardarContacto(contacto);

  @override
  Future<ContactoSimpleModel> getContactoSimplePorIdContacto(
    int idContacto,
  ) => _remote.getContactoSimplePorIdContacto(idContacto);

  @override
  Future<CrudResult> guardarContactoSimple(ContactoSimple contacto) =>
      _remote.guardarContactoSimple(contacto);
}
