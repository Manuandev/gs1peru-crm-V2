// lib/features/chat/domain/usecases/get_info_lead_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';
import 'package:app_crm/features/lead/index_lead.dart';

class GetInfoUseCase {
  final ChatRepository repository;
  const GetInfoUseCase(this.repository);

  Future<Negociacion> call(int idLead) => repository.getInfoNegociacion(idLead);
}
