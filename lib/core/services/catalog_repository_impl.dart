// lib/core/services/catalog_repository_impl.dart

import 'package:app_crm/core/index_core.dart';

class CatalogsRepositoryImpl implements CatalogsRepository {
  final CatalogsRemoteDatasource _remote;

  CatalogsRepositoryImpl(this._remote);

  @override
  Future<ListasGenericas> getListas() => _remote.getListas();
}
