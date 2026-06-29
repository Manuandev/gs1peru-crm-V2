// lib/features/chat/domain/usecases/update_lead_info_usecase.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class UpdateLeadInfoUseCase {
  final LeadRepository repository;

  const UpdateLeadInfoUseCase(this.repository);

  Future<CrudResult> call(
    Lead leadModificado, {
    String empresaEditar = '',
    String correoEditar = '',
    String nuevasEmpresas = '',
    String nuevosCorreos = '',
    String nuevosPrefijos = '',
    String nuevosNumeros = '',
  }) async {
    return await repository.updateLeadCompleto(
      leadModificado,
      empresaEditar: empresaEditar,
      correoEditar: correoEditar,
      nuevasEmpresas: nuevasEmpresas,
      nuevosCorreos: nuevosCorreos,
      nuevosPrefijos: nuevosPrefijos,
      nuevosNumeros: nuevosNumeros,
    );
  }
}
