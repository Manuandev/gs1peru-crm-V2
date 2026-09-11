// lib/features/lead/presentation/bloc/seguimiento/seguimiento_event.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/lead/index_lead.dart';

sealed class SeguimientoEvento extends Equatable {
  const SeguimientoEvento();

  @override
  List<Object?> get props => [];
}

/// Primera carga de la pantalla.
class SeguimientoIniciado extends SeguimientoEvento {
  const SeguimientoIniciado();
}

/// Pull-to-refresh: resetea items + cursor + contadores y pide desde cero.
class SeguimientoRefrescado extends SeguimientoEvento {
  const SeguimientoRefrescado();
}

/// Cambio de chip: lista independiente — resetea todo y pide con otro filtro.
class SeguimientoFiltroCambiado extends SeguimientoEvento {
  final LeadListFiltro filtro;
  const SeguimientoFiltroCambiado(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// "Buscar" del panel lateral: aplica fecha/campaña/oportunidad y recarga desde
/// cero (mantiene el chip activo). Contadores y lista se recalculan en el SP.
class SeguimientoFiltroAvanzadoAplicado extends SeguimientoEvento {
  final SeguimientoFiltroAvanzado filtro;
  const SeguimientoFiltroAvanzadoAplicado(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// "Limpiar" del panel lateral: quita todos los filtros avanzados y recarga.
class SeguimientoFiltroAvanzadoLimpiado extends SeguimientoEvento {
  const SeguimientoFiltroAvanzadoLimpiado();
}

/// Texto del buscador del AppBar (llega en cada tecla). El bloc espera
/// `AppConstants.debounceBusqueda` tras la última tecla y recién ahí recarga
/// desde la página 1. El filtro lo aplica el SP ('LSP', campo 13) junto con
/// el chip y el panel (AND). '' (la X del buscador) limpia al toque.
class SeguimientoBusquedaCambiada extends SeguimientoEvento {
  final String texto;
  const SeguimientoBusquedaCambiada(this.texto);

  @override
  List<Object?> get props => [texto];
}

/// El scroll llegó al umbral (80%) — pedir la página siguiente. Se ignora si ya
/// hay una en vuelo, si se llegó al final, o si el pie está mostrando un error
/// (ahí solo dispara [SeguimientoReintentarPagina]).
class SeguimientoPaginaSolicitada extends SeguimientoEvento {
  const SeguimientoPaginaSolicitada();
}

/// Botón "Reintentar" del pie tras un fallo de página.
class SeguimientoReintentarPagina extends SeguimientoEvento {
  const SeguimientoReintentarPagina();
}

/// Parche en memoria tras editar una negociación en la propia app
/// (LeadUpdateNotifier). No llega por cambios de otros usuarios (sin push).
class SeguimientoLeadActualizado extends SeguimientoEvento {
  final Negociacion negociacion;
  const SeguimientoLeadActualizado(this.negociacion);

  @override
  List<Object?> get props => [negociacion];
}
