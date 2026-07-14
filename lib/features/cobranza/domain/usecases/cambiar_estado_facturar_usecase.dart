// lib/features/cobranza/domain/usecases/cambiar_estado_facturar_usecase.dart

import 'package:app_crm/core/network/crud_result.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CambiarEstadoFacturarUseCase {
  final CobranzaRepository _repository;
  const CambiarEstadoFacturarUseCase(this._repository);

  Future<CrudResult> call({
    required String numSol,
    required String estado,
    required String condicionPago,
    required String fechaVencimiento,
    required String ordenCompra,
    required String descripcionSugerida,
    required String hojaAceptacion,
  }) => _repository.cambiarEstadoFacturar(
        numSol: numSol,
        estado: estado,
        condicionPago: condicionPago,
        fechaVencimiento: fechaVencimiento,
        ordenCompra: ordenCompra,
        descripcionSugerida: descripcionSugerida,
        hojaAceptacion: hojaAceptacion,
      );
}
