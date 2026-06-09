// lib/features/cobranza/domain/repositories/cobranza_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaRepository {
  Future<List<Cobranza>> getCobranzas();
  Future<CobranzaDetalle?> getDetalleCobranza(String numSol);

  Future<CrudResult> guardarBorrador(int idCobranza);
  Future<CrudResult> facturarContado(int idCobranza);
  Future<CrudResult> guardarPlanCredito(int idCobranza, List<CuotaPlan> cuotas);
}
