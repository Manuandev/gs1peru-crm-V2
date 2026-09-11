// lib/core/services/catalog_repository.dart

import 'package:app_crm/core/index_core.dart';

abstract class CatalogsRepository {
  Future<ListasGenericas> getListas();
  Future<TipoCambioItem> getTipoCambio();
  /// [ambito] decide de qué tabla sale el universo — ver [AsesorAmbito].
  Future<List<AsesorItem>> getAsesores({AsesorAmbito ambito});
  Future<
    ({
      List<CampaniaItem> campanias,
      List<OportunidadItem> oportunidades,
      List<EventoItem> eventos,
    })
  >
  getFiltros();
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
  getCatalogosEditarNegociacion();
}