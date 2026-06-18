// lib/features/lead/domain/usecases/toggle_favorito_lead_usecase.dart

import 'package:app_crm/features/lead/index_lead.dart';

class ToggleFavoritoLeadUseCase {
  final LeadRepository _repository;
  const ToggleFavoritoLeadUseCase(this._repository);

  Future<void> call(int idLead, bool isFavorito) =>
      _repository.toggleFavorito(idLead, isFavorito);
}
