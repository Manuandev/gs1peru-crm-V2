// lib/features/cobranza/data/repositories/cobranza_repository_impl.dart

import 'package:app_crm/core/network/crud_result.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaRepositoryImpl implements CobranzaRepository {
  final CobranzaRemoteDatasource _remote;

  CobranzaRepositoryImpl(this._remote);

  @override
  Future<List<Cobranza>> getCobranzas() => _remote.getCobranzas();

  @override
  Future<CobranzaPagina> traerPagina({
    CobranzaChipFiltro chip = CobranzaChipFiltro.todos,
    String? codAsesor,
    String? cursorFecha,
    String? cursorNumSol,
    required int tamanio,
    DateTime? fcDesde,
    DateTime? fcHasta,
    int? idCampania,
    int? idOportunidad,
    Set<int> estados = const {},
  }) => _remote.traerPagina(
    chip: chip,
    codAsesor: codAsesor,
    cursorFecha: cursorFecha,
    cursorNumSol: cursorNumSol,
    tamanio: tamanio,
    fcDesde: fcDesde,
    fcHasta: fcHasta,
    idCampania: idCampania,
    idOportunidad: idOportunidad,
    estados: estados,
  );

  @override
  Future<CobranzaDetalle?> getDetalleCobranza(String numSol) =>
      _remote.getDetalleCobranza(numSol);

  @override
  Future<CrudResult> cambiarEstadoFacturar({
    required String numSol,
    required String estado,
    required String condicionPago,
    required String fechaVencimiento,
    required String ordenCompra,
    required String descripcionSugerida,
    required String hojaAceptacion,
  }) => _remote.cambiarEstadoFacturar(
        numSol: numSol,
        estado: estado,
        condicionPago: condicionPago,
        fechaVencimiento: fechaVencimiento,
        ordenCompra: ordenCompra,
        descripcionSugerida: descripcionSugerida,
        hojaAceptacion: hojaAceptacion,
      );

  @override
  Future<CrudResult> guardarPlanCredito({
    required String numSol,
    required String moneda,
    required List<CuotaPlan> cuotas,
  }) => _remote.guardarPlanCredito(numSol: numSol, moneda: moneda, cuotas: cuotas);
}
