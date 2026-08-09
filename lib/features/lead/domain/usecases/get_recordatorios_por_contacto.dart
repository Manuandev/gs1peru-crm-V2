// lib/features/lead/domain/usecases/get_recordatorios_por_contacto.dart

import 'package:app_crm/features/lead/index_lead.dart';

class GetRecordatoriosPorContacto {
  final LeadRepository _repository;

  GetRecordatoriosPorContacto(this._repository);

  Future<List<LeadRecordatorio>> call(int idContacto) =>
      _repository.obtenerRecordatoriosPorContacto(idContacto);
}
