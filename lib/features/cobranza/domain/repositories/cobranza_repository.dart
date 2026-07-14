// lib/features/cobranza/domain/repositories/cobranza_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaRepository {
  Future<List<Cobranza>> getCobranzas();
  Future<CobranzaDetalle?> getDetalleCobranza(String numSol);

  Future<CrudResult> cambiarEstadoFacturar({
    required String numSol,
    required String estado,
    required String condicionPago,
    required String fechaVencimiento,
    required String ordenCompra,
    required String descripcionSugerida,
    required String hojaAceptacion,
  });

  Future<CrudResult> guardarPlanCredito({
    required String numSol,
    required String moneda,
    required List<CuotaPlan> cuotas,
  });
}
