// lib/core/services/catalog_repository.dart

import 'package:app_crm/core/index_core.dart';

abstract class CatalogsRepository {
  Future<ListasGenericas> getListas();
}