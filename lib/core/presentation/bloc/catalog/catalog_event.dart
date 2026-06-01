// lib/core/presentation/bloc/catalog/catalog_event.dart

import 'package:app_crm/index_dependencies.dart';

abstract class CatalogsEvent extends Equatable {
  const CatalogsEvent();

  @override
  List<Object> get props => [];
}

class CatalogsLoadRequested extends CatalogsEvent {
  const CatalogsLoadRequested();
}
