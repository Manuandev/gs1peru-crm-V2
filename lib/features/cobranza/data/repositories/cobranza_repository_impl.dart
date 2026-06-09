// lib/features/cobranza/data/repositories/cobranza_repository_impl.dart

import 'package:app_crm/core/network/crud_result.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaRepositoryImpl implements CobranzaRepository {
  final CobranzaRemoteDatasource _remote;

  CobranzaRepositoryImpl(this._remote);

  @override
  Future<List<Cobranza>> getCobranzas() => _remote.getCobranzas();

  @override
  Future<CobranzaDetalle?> getDetalleCobranza(String numSol) =>
      _remote.getDetalleCobranza(numSol);

  @override
  Future<CrudResult> guardarBorrador(int idCobranza) =>
      _remote.guardarBorrador(idCobranza);

  @override
  Future<CrudResult> facturarContado(int idCobranza) =>
      _remote.facturarContado(idCobranza);

  @override
  Future<CrudResult> guardarPlanCredito(
    int idCobranza,
    List<CuotaPlan> cuotas,
  ) => _remote.guardarPlanCredito(idCobranza, cuotas);
}
