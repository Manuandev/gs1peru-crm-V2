// lib/core/domain/usecases/get_catalogos_filtros_usecase.dart

import 'package:app_crm/core/index_core.dart';

/// Task 'FIL' — campañas + oportunidades + eventos, para refrescar los combos de
/// filtro al entrar a Conversaciones/Seguimiento/Solicitudes sin recargar el
/// catálogo completo.
class GetCatalogosFiltrosUseCase {
  final CatalogsRepository repository;
  const GetCatalogosFiltrosUseCase(this.repository);

  Future<
    ({
      List<CampaniaItem> campanias,
      List<OportunidadItem> oportunidades,
      List<EventoItem> eventos,
    })
  >
  call() => repository.getFiltros();
}
