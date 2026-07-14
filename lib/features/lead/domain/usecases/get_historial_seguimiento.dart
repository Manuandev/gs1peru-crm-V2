// lib/features/lead/domain/usecases/get_historial_seguimiento.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetHistorialSeguimiento {
  final LeadRepository _repository;

  GetHistorialSeguimiento(this._repository);

  Future<List<HistorialComentario>> call(int idLead) =>
      _repository.obtenerHistorialSeguimiento(idLead);
}
