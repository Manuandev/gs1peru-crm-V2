// lib/features/cobranza/presentation/bloc/lista/cobranza_list_event.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

sealed class CobranzaListEvent extends Equatable {
  const CobranzaListEvent();

  @override
  List<Object?> get props => [];
}

/// Primera carga de la pantalla.
class CobranzaListStarted extends CobranzaListEvent {
  const CobranzaListStarted();
}

/// Pull-to-refresh: resetea items + cursor + contadores y pide desde cero.
class CobranzaListRefresh extends CobranzaListEvent {
  const CobranzaListRefresh();
}

/// Cambia el chip activo (Todos / Asesores / Contado / Crédito) — recarga desde
/// cero con ese filtro (va al SP, task 'LSP' es paginado).
class CobranzaChipChanged extends CobranzaListEvent {
  final CobranzaChipFiltro filtro;
  const CobranzaChipChanged(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// Asesor elegido en CobranzaAsesorPickerModal (chip "Asesores").
class CobranzaAsesorSeleccionado extends CobranzaListEvent {
  final String codAsesor;
  const CobranzaAsesorSeleccionado(this.codAsesor);

  @override
  List<Object?> get props => [codAsesor];
}

/// Activa/desactiva una tarjeta de estado (multi-selección) — el filtro de
/// estado va al SP, así que recarga desde cero.
class CobranzaEstadoToggled extends CobranzaListEvent {
  final int idEstado;
  const CobranzaEstadoToggled(this.idEstado);

  @override
  List<Object?> get props => [idEstado];
}

/// "Buscar" del panel lateral: aplica fecha/campaña/oportunidad y recarga desde
/// cero (mantiene chip y tarjetas). Contadores y lista se recalculan en el SP.
class CobranzaFiltroAvanzadoAplicado extends CobranzaListEvent {
  final CobranzaFiltroAvanzado filtro;
  const CobranzaFiltroAvanzadoAplicado(this.filtro);

  @override
  List<Object?> get props => [filtro];
}

/// "Limpiar" del panel lateral: vuelve al filtro por defecto (mes actual → hoy).
class CobranzaFiltroAvanzadoLimpiado extends CobranzaListEvent {
  const CobranzaFiltroAvanzadoLimpiado();
}

/// El scroll llegó al umbral — pedir la página siguiente.
class CobranzaPaginaSolicitada extends CobranzaListEvent {
  const CobranzaPaginaSolicitada();
}

/// Botón "Reintentar" del pie tras un fallo de página.
class CobranzaReintentarPagina extends CobranzaListEvent {
  const CobranzaReintentarPagina();
}

/// Llega desde CobranzaUpdateNotifier tras facturar — parchea idEstado y
/// condición de pago de esa cobranza en memoria sin recargar del backend.
class CobranzaListItemActualizado extends CobranzaListEvent {
  final String numSol;
  final int idEstado;
  final String idCondicion;
  final String condicion;
  const CobranzaListItemActualizado(
    this.numSol,
    this.idEstado,
    this.idCondicion,
    this.condicion,
  );

  @override
  List<Object?> get props => [numSol, idEstado, idCondicion, condicion];
}
