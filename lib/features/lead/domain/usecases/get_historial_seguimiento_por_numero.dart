// lib/features/lead/domain/usecases/get_historial_seguimiento_por_numero.dart

import 'package:app_crm/features/lead/index_lead.dart';

// 2026-08-03 — migrado de idNumero a idContacto, ver comentario en
// LeadRepository.obtenerHistorialSeguimientoPorContacto.
class GetHistorialSeguimientoPorContacto {
  final LeadRepository _repository;

  GetHistorialSeguimientoPorContacto(this._repository);

  Future<List<HistorialComentario>> call(int idContacto) =>
      _repository.obtenerHistorialSeguimientoPorContacto(idContacto);
}
