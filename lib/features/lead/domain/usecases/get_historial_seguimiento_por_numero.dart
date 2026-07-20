// lib/features/lead/domain/usecases/get_historial_seguimiento_por_numero.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetHistorialSeguimientoPorNumero {
  final LeadRepository _repository;

  GetHistorialSeguimientoPorNumero(this._repository);

  Future<List<HistorialComentario>> call(int idNumero) =>
      _repository.obtenerHistorialSeguimientoPorNumero(idNumero);
}
