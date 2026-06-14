// lib/features/chat/domain/usecases/get_templates_usecase.dart

import 'package:app_crm/features/chat/index_chat.dart';

class GetTemplatesUseCase {
  final ChatRepository repository;
  const GetTemplatesUseCase(this.repository);

  Future<List<Template>> call() => repository.getTemplates();
}
