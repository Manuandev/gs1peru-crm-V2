// lib/core/services/catalog_repository_impl.dart

import 'package:app_crm/core/index_core.dart';

class CatalogsRepositoryImpl implements CatalogsRepository {
  final CatalogsRemoteDatasource _remote;

  CatalogsRepositoryImpl(this._remote);

  @override
  Future<ListasGenericas> getListas() => _remote.getListas();

  @override
  Future<TipoCambioItem> getTipoCambio() => _remote.getTipoCambio();

  @override
  Future<List<AsesorItem>> getAsesores({
    AsesorAmbito ambito = AsesorAmbito.todos,
  }) => _remote.getAsesores(ambito: ambito);

  @override
  Future<
    ({
      List<CampaniaItem> campanias,
      List<OportunidadItem> oportunidades,
      List<EventoItem> eventos,
    })
  >
  getFiltros() => _remote.getFiltros();

  @override
  Future<
    ({
      List<EstadoItem> estados,
      List<CampaniaItem> campanias,
      List<OportunidadItem> oportunidades,
      List<CanalItem> canales,
      List<InteresItem> intereses,
      List<MonedaItem> monedas,
    })
  >
  getCatalogosEditarNegociacion() => _remote.getCatalogosEditarNegociacion();
}
