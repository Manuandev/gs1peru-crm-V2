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

// Refresca solo estados/campañas/oportunidades/canales/intereses/monedas
// (task 'EN') — usado al entrar a "Editar negociación", sin recargar el
// catálogo completo. Si el catálogo todavía no cargó (estado distinto de
// CatalogsLoaded), no hace nada — no hay nada que fusionar todavía.
class CatalogsNegociacionRefreshed extends CatalogsEvent {
  const CatalogsNegociacionRefreshed();
}

// Refresca solo campañas + oportunidades + eventos (task 'FIL') — usado al
// entrar a Conversaciones/Seguimiento (leen campañas+oportunidades) y a
// Solicitudes (lee campañas+eventos) para mantener los combos de filtro
// frescos. Falla en silencio; si el catálogo todavía no cargó, no hace nada.
class CatalogsFiltrosRefreshed extends CatalogsEvent {
  const CatalogsFiltrosRefreshed();
}
