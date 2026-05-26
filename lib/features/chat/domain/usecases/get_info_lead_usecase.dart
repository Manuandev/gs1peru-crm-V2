// lib\features\chat\domain\usecases\get_info_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class GetInfoUseCase {
  final ChatRepository repository;
  const GetInfoUseCase(this.repository);

  Future<InfoLead> call(int idLead) => repository.getInfoLead(idLead);
}
