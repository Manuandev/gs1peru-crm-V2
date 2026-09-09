// lib/features/cobranza/presentation/bloc/lista/cobranza_list_state.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

sealed class CobranzaListState extends Equatable {
  const CobranzaListState();

  @override
  List<Object?> get props => [];
}

class CobranzaListInitial extends CobranzaListState {
  const CobranzaListInitial();
}

/// SOLO la primera carga de la pantalla → skeleton completo. El cambio de chip /
/// tarjeta / aplicar filtro / refresh NO pasan por acá: se resuelven con
/// [CobranzaListCargado.recargandoLista] para no desmontar tarjetas ni chips.
class CobranzaListCargando extends CobranzaListState {
  const CobranzaListCargando();
}

/// Falla en la PRIMERA carga (lista todavía vacía).
class CobranzaListErrorInicial extends CobranzaListState {
  final String mensaje;
  const CobranzaListErrorInicial(this.mensaje);

  @override
  List<Object?> get props => [mensaje];
}

class CobranzaListCargado extends CobranzaListState {
  final List<Cobranza> items;
  final CobranzaChipFiltro chipFiltro;
  final String? asesorSeleccionado;

  /// Set vacío = las 4 tarjetas activas (sin filtro de estado).
  final Set<int> estadosSeleccionados;

  final CobranzaConteos conteos;
  final CobranzaFiltroAvanzado filtroAvanzado;

  /// Conteo de cobranzas por asesor (codUser) desglosado por idEstado, sobre las
  /// páginas ya cargadas (best-effort) — alimenta CobranzaAsesorPickerModal.
  final Map<String, Map<int, int>> conteosPorAsesor;

  final bool recargandoLista;
  final bool finLista;
  final bool cargandoMas;
  final String? loadMoreError;
  final String? cursorFecha;
  final String? cursorNumSol;

  const CobranzaListCargado({
    required this.items,
    required this.chipFiltro,
    required this.estadosSeleccionados,
    required this.conteos,
    this.asesorSeleccionado,
    this.filtroAvanzado = CobranzaFiltroAvanzado.vacio,
    this.conteosPorAsesor = const {},
    this.recargandoLista = false,
    this.finLista = false,
    this.cargandoMas = false,
    this.loadMoreError,
    this.cursorFecha,
    this.cursorNumSol,
  });

  /// Pend. de documento GLOBAL (sin el filtro del panel) — alimenta el badge
  /// "Cobranza" del drawer.
  int get pendientesDocumento => conteos.pendGlobal;

  /// El botón de filtro del AppBar se pinta naranja solo si el asesor cambió el
  /// filtro respecto al default (mes actual → hoy).
  bool get tieneFiltroAvanzado => filtroAvanzado.esDistintoDelDefecto;

  bool get puedePaginar =>
      !finLista &&
      !cargandoMas &&
      loadMoreError == null &&
      cursorFecha != null &&
      cursorNumSol != null;

  CobranzaListCargado copyWith({
    List<Cobranza>? items,
    CobranzaChipFiltro? chipFiltro,
    String? asesorSeleccionado,
    Set<int>? estadosSeleccionados,
    CobranzaConteos? conteos,
    CobranzaFiltroAvanzado? filtroAvanzado,
    Map<String, Map<int, int>>? conteosPorAsesor,
    bool? recargandoLista,
    bool? finLista,
    bool? cargandoMas,
    String? loadMoreError,
    bool limpiarLoadMoreError = false,
    String? cursorFecha,
    String? cursorNumSol,
    bool limpiarAsesor = false,
  }) {
    return CobranzaListCargado(
      items: items ?? this.items,
      chipFiltro: chipFiltro ?? this.chipFiltro,
      asesorSeleccionado:
          limpiarAsesor ? null : (asesorSeleccionado ?? this.asesorSeleccionado),
      estadosSeleccionados: estadosSeleccionados ?? this.estadosSeleccionados,
      conteos: conteos ?? this.conteos,
      filtroAvanzado: filtroAvanzado ?? this.filtroAvanzado,
      conteosPorAsesor: conteosPorAsesor ?? this.conteosPorAsesor,
      recargandoLista: recargandoLista ?? this.recargandoLista,
      finLista: finLista ?? this.finLista,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      loadMoreError: limpiarLoadMoreError
          ? null
          : (loadMoreError ?? this.loadMoreError),
      cursorFecha: cursorFecha ?? this.cursorFecha,
      cursorNumSol: cursorNumSol ?? this.cursorNumSol,
    );
  }

  @override
  List<Object?> get props => [
    items,
    chipFiltro,
    asesorSeleccionado,
    estadosSeleccionados,
    conteos.porEstado,
    conteos.pendGlobal,
    filtroAvanzado,
    recargandoLista,
    finLista,
    cargandoMas,
    loadMoreError,
    cursorFecha,
    cursorNumSol,
  ];
}
