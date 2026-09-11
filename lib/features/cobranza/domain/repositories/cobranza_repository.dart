// lib/features/cobranza/domain/repositories/cobranza_repository.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

abstract class CobranzaRepository {
  Future<List<Cobranza>> getCobranzas();

  Future<CobranzaPagina> traerPagina({
    CobranzaChipFiltro chip,
    String? codAsesor,
    String? cursorFecha,
    String? cursorNumSol,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
    Set<int> estados,
    String busqueda,
  });

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
