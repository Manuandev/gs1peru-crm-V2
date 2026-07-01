// lib/features/lead/domain/usecases/get_historial_comentarios.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetHistorialComentarios {
  final LeadRepository _repository;

  GetHistorialComentarios(this._repository);

  Future<List<HistorialComentario>> call(int idNumero) =>
      _repository.obtenerHistorialComentarios(idNumero);
}
