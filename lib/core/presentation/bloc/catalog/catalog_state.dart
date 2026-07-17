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

  List<CampaniaItem> get campanias => listas.campanias;
  List<OportunidadItem> get oportunidades => listas.oportunidades;
  List<CanalItem> get canales => listas.canales;
  List<InteresItem> get intereses => listas.intereses;
  List<EstadoItem> get estados => listas.estados;
  List<AsesorItem> get asesores => listas.asesores;
  List<EstadoGestionItem> get estadosGestion => listas.estadosGestion;
  List<MonedaItem> get monedas => listas.monedas;
  double get igvPorcentaje => listas.igvPorcentaje;
  List<PaisItem> get paises => listas.paises;
  List<TipoDocumentoItem> get tiposDocumento => listas.tiposDocumento;
  List<ComprobanteItem> get comprobantes => listas.comprobantes;
  List<NacionalidadItem> get nacionalidades => listas.nacionalidades;
  ValoresCRMItem get valoresDefecto => listas.valoresDefecto;
  List<SexoItem> get sexos => listas.sexos;
  List<TipoParticipanteItem> get tiposParticipante => listas.tiposParticipante;
  List<UbigeoItem> get ubigeo => listas.ubigeo;
  List<CanalExpoItem> get canalesExpo => listas.canalesExpo;

  @override
  List<Object?> get props => [
    campanias,
    oportunidades,
    canales,
    intereses,
    estados,
    asesores,
    estadosGestion,
    monedas,
    igvPorcentaje,
    paises,
    tiposDocumento,
    comprobantes,
    nacionalidades,
    valoresDefecto,
    sexos,
    tiposParticipante,
    ubigeo,
    canalesExpo,
  ];
}

class CatalogsError extends CatalogsState {
  final String message;
  const CatalogsError(this.message);

  @override
  List<Object?> get props => [message];
}
