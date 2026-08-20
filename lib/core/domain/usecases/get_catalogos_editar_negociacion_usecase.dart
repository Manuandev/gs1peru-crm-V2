// lib/core/domain/usecases/get_catalogos_editar_negociacion_usecase.dart

import 'package:app_crm/core/index_core.dart';

class GetCatalogosEditarNegociacionUseCase {
  final CatalogsRepository repository;
  const GetCatalogosEditarNegociacionUseCase(this.repository);

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
  call() => repository.getCatalogosEditarNegociacion();
}
