// lib/features/solicitudes/presentation/bloc/list/solicitud_list_event.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

abstract class SolicitudListEvent extends Equatable {
  const SolicitudListEvent();

  @override
  List<Object?> get props => [];
}

class SolicitudListStarted extends SolicitudListEvent {
  const SolicitudListStarted();
}

/// Pull-to-refresh / reintentar: recarga desde cero con el filtro actual.
class SolicitudListRefresh extends SolicitudListEvent {
  const SolicitudListRefresh();
}

/// Cambio de chip (Todas / Sin validar / Validados). "Asesores" no llega acá —
/// va por [SolicitudListAsesorSeleccionado].
class SolicitudListFiltered extends SolicitudListEvent {
  final SolicitudFiltro filtro;
  const SolicitudListFiltered(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// Texto del buscador del AppBar (llega en cada tecla). El bloc espera
/// `AppConstants.debounceBusqueda` tras la última tecla y recarga desde la
/// página 1. El filtro lo aplica el SP ('LSP', campo 12) junto con el chip y
/// el panel (AND). '' (la X del buscador) limpia al toque.
class SolicitudListSearched extends SolicitudListEvent {
  final String query;
  const SolicitudListSearched(this.query);

  @override
  List<Object?> get props => [query];
}

/// Chip "Asesores" — filtra por el codUser elegido en el picker. `null` = volver
/// a "Todas".
class SolicitudListAsesorSeleccionado extends SolicitudListEvent {
  final String? codAsesor;
  const SolicitudListAsesorSeleccionado(this.codAsesor);

  @override
  List<Object?> get props => [codAsesor];
}

/// "Buscar" del panel lateral: aplica Desde/Hasta/Campaña/Evento y recarga.
class SolicitudFiltroAvanzadoAplicado extends SolicitudListEvent {
  final SolicitudFiltroAvanzado filtro;
  const SolicitudFiltroAvanzadoAplicado(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// "Limpiar" del panel lateral: vuelve al filtro por defecto (mes actual → hoy).
class SolicitudFiltroAvanzadoLimpiado extends SolicitudListEvent {
  const SolicitudFiltroAvanzadoLimpiado();
}

/// Scroll llegó al umbral — pedir la página siguiente.
class SolicitudPaginaSolicitada extends SolicitudListEvent {
  const SolicitudPaginaSolicitada();
}

/// Botón "Reintentar" del pie tras un fallo de página siguiente.
class SolicitudReintentarPagina extends SolicitudListEvent {
  const SolicitudReintentarPagina();
}
