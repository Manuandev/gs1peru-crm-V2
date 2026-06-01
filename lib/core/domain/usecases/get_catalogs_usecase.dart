// lib/core/domain/usecases/get_catalogs_usecase.dart


import 'package:app_crm/core/index_core.dart';

class GetCatalogsUseCase {
  final CatalogsRepository repository;
  const GetCatalogsUseCase(this.repository);

  Future<ListasGenericas> call() => repository.getListas();
}
