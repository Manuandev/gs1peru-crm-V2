// lib/features/cobranza/presentation/bloc/lista/cobranza_list_bloc.dart
//
// BLoC de Cobranzas PAGINADO (task 'LSP' de CRM.CSV_COBRANZAS_LST_APP). Mismo
// patrón que SeguimientoBloc / SolicitudListBloc:
//   - "restartable" (chip / tarjeta de estado / filtro del panel / refresh):
//     contador [_epoca]; la respuesta que vuelve con una época vieja se descarta.
//   - "droppable" (página siguiente): flag síncrono [_cargandoPagina].
// Cambio de chip / tarjeta / filtro NO tumban la pantalla: si ya hay
// CobranzaListCargado se emite con recargandoLista:true (tarjetas + chips
// montados, solo la lista muestra loading). El skeleton completo
// (CobranzaListCargando) es solo la primera carga.

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListBloc extends Bloc<CobranzaListEvent, CobranzaListState> {
  final GetCobranzaPaginaUseCase _getPagina;

  CobranzaChipFiltro _chip = CobranzaChipFiltro.todos;
  String? _asesorSeleccionado;

  // Set vacío = las 4 tarjetas activas (sin filtro de estado).
  Set<int> _estados = {};
  static const _todosLosEstados = {2, 0, 5, 3};

  // Filtro del panel lateral. Al entrar arranca en el default (mes actual → hoy);
  // excepción: desde el embudo de Home (sinRangoFecha:true) arranca SIN fecha.
  CobranzaFiltroAvanzado _filtroAvanzado;

  int _epoca = 0;
  bool _cargandoPagina = false;
  StreamSubscription<CobranzaUpdate>? _updateSub;

  CobranzaListBloc(this._getPagina, {bool sinRangoFecha = false})
    : _filtroAvanzado = sinRangoFecha
          ? CobranzaFiltroAvanzado.sinRango()
          : CobranzaFiltroAvanzado.porDefecto(),
      super(const CobranzaListInitial()) {
    on<CobranzaListStarted>(_onStarted);
    on<CobranzaListRefresh>(_onRefresh);
    on<CobranzaChipChanged>(_onChipChanged);
    on<CobranzaAsesorSeleccionado>(_onAsesorSeleccionado);
    on<CobranzaEstadoToggled>(_onEstadoToggled);
    on<CobranzaFiltroAvanzadoAplicado>(_onFiltroAvanzadoAplicado);
    on<CobranzaFiltroAvanzadoLimpiado>(_onFiltroAvanzadoLimpiado);
    on<CobranzaPaginaSolicitada>(_onPaginaSolicitada);
    on<CobranzaReintentarPagina>(_onReintentarPagina);
    on<CobranzaListItemActualizado>(_onItemActualizado);

    _updateSub = CobranzaUpdateNotifier.instance.stream.listen((update) {
      if (!isClosed) {
        add(
          CobranzaListItemActualizado(
            update.numSol,
            update.idEstado,
            update.idCondicion,
            update.condicion,
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _updateSub?.cancel();
    return super.close();
  }

  // ── Carga desde cero ───────────────────────────────────────────────────────

  Future<void> _onStarted(
    CobranzaListStarted event,
    Emitter<CobranzaListState> emit,
  ) => _cargarDesdeCero(emit);

  Future<void> _onRefresh(
    CobranzaListRefresh event,
    Emitter<CobranzaListState> emit,
  ) => _cargarDesdeCero(emit);

  Future<void> _onChipChanged(
    CobranzaChipChanged event,
    Emitter<CobranzaListState> emit,
  ) {
    if (event.filtro == _chip && state is CobranzaListCargado) {
      return Future.value();
    }
    _chip = event.filtro;
    if (_chip != CobranzaChipFiltro.asesores) _asesorSeleccionado = null;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onAsesorSeleccionado(
    CobranzaAsesorSeleccionado event,
    Emitter<CobranzaListState> emit,
  ) {
    _asesorSeleccionado = event.codAsesor;
    _chip = CobranzaChipFiltro.asesores;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onEstadoToggled(
    CobranzaEstadoToggled event,
    Emitter<CobranzaListState> emit,
  ) {
    final id = event.idEstado;
    final actuales = Set<int>.from(
      _estados.isEmpty ? _todosLosEstados : _estados,
    );
    if (actuales.contains(id)) {
      if (actuales.length == 1) return Future.value(); // no dejar 0 activos
      actuales.remove(id);
    } else {
      actuales.add(id);
    }
    // Si están las 4 → set vacío (= sin filtro de estado).
    _estados = actuales.length == _todosLosEstados.length ? {} : actuales;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onFiltroAvanzadoAplicado(
    CobranzaFiltroAvanzadoAplicado event,
    Emitter<CobranzaListState> emit,
  ) {
    _filtroAvanzado = event.filtro;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onFiltroAvanzadoLimpiado(
    CobranzaFiltroAvanzadoLimpiado event,
    Emitter<CobranzaListState> emit,
  ) {
    final defecto = CobranzaFiltroAvanzado.porDefecto();
    if (_filtroAvanzado == defecto && state is CobranzaListCargado) {
      return Future.value();
    }
    _filtroAvanzado = defecto;
    return _cargarDesdeCero(emit);
  }

  Future<void> _cargarDesdeCero(Emitter<CobranzaListState> emit) async {
    final epoca = ++_epoca;
    _cargandoPagina = false;

    final actual = state;
    if (actual is CobranzaListCargado) {
      emit(actual.copyWith(recargandoLista: true, limpiarLoadMoreError: true));
    } else {
      emit(const CobranzaListCargando());
    }

    try {
      final pagina = await _getPagina(
        chip: _chip,
        codAsesor: _asesorSeleccionado,
        cursorFecha: null,
        cursorNumSol: null,
        tamanio: CobranzaRemoteDatasource.tamanioPrimera,
        fcDesde: _filtroAvanzado.desdeEfectivo,
        fcHasta: _filtroAvanzado.hastaEfectivo,
        idCampania: _filtroAvanzado.idCampania,
        idOportunidad: _filtroAvanzado.idOportunidad,
        estados: _estados,
      );
      if (epoca != _epoca || emit.isDone) return;

      final items = pagina.items;
      emit(
        CobranzaListCargado(
          items: items,
          chipFiltro: _chip,
          asesorSeleccionado: _asesorSeleccionado,
          estadosSeleccionados: Set.from(_estados),
          conteos: pagina.conteos ?? const CobranzaConteos(),
          filtroAvanzado: _filtroAvanzado,
          conteosPorAsesor: _conteosPorAsesor(items),
          recargandoLista: false,
          finLista: items.length < CobranzaRemoteDatasource.tamanioPrimera,
          cursorFecha: pagina.cursorFecha,
          cursorNumSol: pagina.cursorNumSol,
        ),
      );
    } catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      emit(CobranzaListErrorInicial(_mensajeError(e)));
    }
  }

  // ── Página siguiente ───────────────────────────────────────────────────────

  Future<void> _onPaginaSolicitada(
    CobranzaPaginaSolicitada event,
    Emitter<CobranzaListState> emit,
  ) async {
    final s = state;
    if (s is! CobranzaListCargado) return;
    if (s.recargandoLista || s.loadMoreError != null || !s.puedePaginar) return;
    await _traerSiguiente(emit, s);
  }

  Future<void> _onReintentarPagina(
    CobranzaReintentarPagina event,
    Emitter<CobranzaListState> emit,
  ) async {
    final s = state;
    if (s is! CobranzaListCargado || s.cargandoMas || s.finLista) return;
    if (s.cursorFecha == null || s.cursorNumSol == null) return;
    await _traerSiguiente(emit, s.copyWith(limpiarLoadMoreError: true));
  }

  Future<void> _traerSiguiente(
    Emitter<CobranzaListState> emit,
    CobranzaListCargado s,
  ) async {
    if (_cargandoPagina) return;
    _cargandoPagina = true;
    final epoca = _epoca;
    emit(s.copyWith(cargandoMas: true, limpiarLoadMoreError: true));

    try {
      final pagina = await _getPagina(
        chip: s.chipFiltro,
        codAsesor: s.asesorSeleccionado,
        cursorFecha: s.cursorFecha,
        cursorNumSol: s.cursorNumSol,
        tamanio: CobranzaRemoteDatasource.tamanioSiguiente,
        fcDesde: _filtroAvanzado.desdeEfectivo,
        fcHasta: _filtroAvanzado.hastaEfectivo,
        idCampania: _filtroAvanzado.idCampania,
        idOportunidad: _filtroAvanzado.idOportunidad,
        estados: _estados,
      );
      if (epoca != _epoca || emit.isDone) return;

      final yaCargados = s.items.map((c) => c.numSol).toSet();
      final nuevos =
          pagina.items.where((c) => !yaCargados.contains(c.numSol)).toList();
      final items = [...s.items, ...nuevos];

      emit(
        s.copyWith(
          items: items,
          conteosPorAsesor: _conteosPorAsesor(items),
          cargandoMas: false,
          finLista: pagina.items.length <
              CobranzaRemoteDatasource.tamanioSiguiente,
          cursorFecha: pagina.cursorFecha ?? s.cursorFecha,
          cursorNumSol: pagina.cursorNumSol ?? s.cursorNumSol,
        ),
      );
    } catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      emit(s.copyWith(cargandoMas: false, loadMoreError: _mensajeError(e)));
    } finally {
      _cargandoPagina = false;
    }
  }

  // ── Parche por edición local (facturar) ────────────────────────────────────

  void _onItemActualizado(
    CobranzaListItemActualizado event,
    Emitter<CobranzaListState> emit,
  ) {
    final s = state;
    if (s is! CobranzaListCargado) return;
    final label = cobranzaEstadoLabel(event.idEstado);
    final items = s.items
        .map(
          (c) => c.numSol == event.numSol
              ? c.copyWith(
                  idEstado: event.idEstado,
                  estado: label.isNotEmpty ? label : null,
                  idCondicion: event.idCondicion,
                  condicion: event.condicion,
                )
              : c,
        )
        .toList();
    emit(s.copyWith(items: items, conteosPorAsesor: _conteosPorAsesor(items)));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Map<String, Map<int, int>> _conteosPorAsesor(List<Cobranza> items) {
    final conteos = <String, Map<int, int>>{};
    for (final c in items) {
      if (c.asignadoA.isEmpty) continue;
      final porEstado = conteos.putIfAbsent(c.asignadoA, () => {});
      porEstado[c.idEstado] = (porEstado[c.idEstado] ?? 0) + 1;
    }
    return conteos;
  }

  String _mensajeError(Object e) =>
      e is AppException ? e.message : 'No se pudieron cargar las cobranzas.';
}
