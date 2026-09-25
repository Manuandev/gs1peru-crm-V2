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

  /// Unidad de negocio activa (UnidadCubit) — `null` si el asesor no tiene
  /// unidades: en ese caso los combos por unidad salen vacíos.
  final int? idUnidad;

  const CatalogsLoaded({required this.listas, this.idUnidad});

  // ── Combos filtrados por la unidad activa ───────────────────
  // Campañas de la unidad; oportunidades y eventos en cascada por idCampania.
  List<CampaniaItem> get campanias => idUnidad == null
      ? const []
      : listas.campanias.where((c) => c.idUnidad == idUnidad).toList();
  Set<int> get _idsCampaniasUnidad => campanias.map((c) => c.id).toSet();
  List<OportunidadItem> get oportunidades {
    final ids = _idsCampaniasUnidad;
    return listas.oportunidades
        .where((o) => ids.contains(o.idCampania))
        .toList();
  }

  List<EventoItem> get eventos {
    final ids = _idsCampaniasUnidad;
    return listas.eventos.where((e) => ids.contains(e.idCampania)).toList();
  }

  /// Asesores de la unidad activa — para los pickers/combos de asesores.
  /// [asesores] (sin filtrar) se mantiene para resolver el NOMBRE de un
  /// codUser cualquiera (ej. quién creó un recordatorio).
  List<AsesorItem> get asesoresUnidad => idUnidad == null
      ? const []
      : listas.asesores.where((a) => a.unidades.contains(idUnidad)).toList();

  /// Catálogo completo de unidades (para resolver nombres).
  List<UnidadNegocioItem> get unidades => listas.unidades;

  /// Nombre de la unidad [id], o `null` si el catálogo no la trae.
  String? nombreUnidad(int? id) =>
      listas.unidades.where((u) => u.id == id).firstOrNull?.nombre;

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
  List<AreaItem> get areas => listas.areas;
  List<CargoItem> get cargos => listas.cargos;
  List<PrefijoContactoItem> get prefijosContacto => listas.prefijosContacto;
  TipoCambioItem get tipoCambio => listas.tipoCambio;

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
    areas,
    cargos,
    prefijosContacto,
    tipoCambio,
    eventos,
    unidades,
    idUnidad,
  ];
}

class CatalogsError extends CatalogsState {
  final String message;
  const CatalogsError(this.message);

  @override
  List<Object?> get props => [message];
}
