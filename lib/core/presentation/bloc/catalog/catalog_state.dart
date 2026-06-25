// lib/core/presentation/bloc/catalog/catalog_state.dart

import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/index_dependencies.dart';

abstract class CatalogsState extends Equatable {
  const CatalogsState();

  @override
  List<Object?> get props => [];
}

class CatalogsInitial extends CatalogsState {
  const CatalogsInitial();
}

class CatalogsLoading extends CatalogsState {
  const CatalogsLoading();
}

class CatalogsLoaded extends CatalogsState {
  final ListasGenericas listas;

  const CatalogsLoaded({required this.listas});

  List<CampaniaItem>    get campanias    => listas.campanias;
  List<OportunidadItem> get oportunidades => listas.oportunidades;
  List<CanalItem>       get canales      => listas.canales;
  List<InteresItem>     get intereses    => listas.intereses;
  List<EstadoItem>      get estados      => listas.estados;

  @override
  List<Object?> get props => [campanias, oportunidades, canales, intereses, estados];
}

class CatalogsError extends CatalogsState {
  final String message;
  const CatalogsError(this.message);

  @override
  List<Object?> get props => [message];
}
