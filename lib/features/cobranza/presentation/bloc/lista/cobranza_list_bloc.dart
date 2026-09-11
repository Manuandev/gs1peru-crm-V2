// lib/features/cobranza/presentation/bloc/lista/cobranza_list_bloc.dart
//
// BLoC de Cobranzas PAGINADO (task 'LSP' de CRM.CSV_COBRANZAS_LST_APP). Mismo
// patrón que SeguimientoBloc / SolicitudListBloc:
//   - "restartable" (chip / tarjeta de estado / filtro del panel / refresh /
//     búsqueda): contador [_epoca]; la respuesta que vuelve con una época vieja
//     se descarta.
//   - "droppable" (página siguiente): flag síncrono [_cargandoPagina].
//   - "debounce" (buscador del AppBar): ticket [_ticketBusqueda], mismo estilo
//     que [_epoca] — cada tecla saca uno nuevo y tras la espera solo sigue el
//     último.
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

  // Texto del buscador ya normalizado ('' = sin búsqueda). Se combina con chip
  // + tarjetas + panel (AND en el SP) y viaja en TODAS las páginas — ver
  // [_pedirPagina].
  String _busqueda = '';
  int _ticketBusqueda = 0;

  // {codUser: {idEstadoGes: cantidad}} del picker "Asesores". Lo manda el SP en
  // la primera página sobre TODO el universo filtrado — antes se sumaba acá
  // sobre los items ya cargados y un asesor con 141 cancelados mostraba las 9
  // filas que habían entrado en la primera página.
  Map<String, Map<int, int>> _conteosPorAsesor = const {};

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
    on<CobranzaBusquedaCambiada>(_onBusquedaCambiada);
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

  // ── Búsqueda (buscador del AppBar) ─────────────────────────────────────────

  Future<void> _onBusquedaCambiada(
    CobranzaBusquedaCambiada event,
    Emitter<CobranzaListState> emit,
  ) async {
    final texto = event.texto.trim();

    // Debounce: cada tecla saca un ticket; tras la espera solo sigue la última.
    // Vacío (la X del buscador) limpia al toque, sin esperar.
    final ticket = ++_ticketBusqueda;
    if (texto.isNotEmpty) await Future.delayed(AppConstants.debounceBusqueda);
    if (ticket != _ticketBusqueda || isClosed || emit.isDone) return;

    // Por debajo del mínimo de caracteres no filtra (con 1-2 letras traería
    // media base y no aporta).
    final busqueda = texto.length >= AppConstants.busquedaMinCaracteres
        ? texto
        : '';
    if (busqueda == _busqueda && state is CobranzaListCargado) return;
    _busqueda = busqueda;
    await _cargarDesdeCero(emit);
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
      final pagina = await _pedirPagina(
        chip: _chip,
        codAsesor: _asesorSeleccionado,
        tamanio: CobranzaRemoteDatasource.tamanioPrimera,
      );
      if (epoca != _epoca || emit.isDone) return;

      final items = pagina.items;
      // Fallback al cálculo viejo (sobre lo cargado) solo si el SP no trae el
      // bloque — app nueva contra un SP aún no desplegado.
      _conteosPorAsesor =
          pagina.conteosPorAsesor ?? _conteosPorAsesorLocal(items);
      emit(
        CobranzaListCargado(
          items: items,
          chipFiltro: _chip,
          asesorSeleccionado: _asesorSeleccionado,
          estadosSeleccionados: Set.from(_estados),
          conteos: pagina.conteos ?? const CobranzaConteos(),
          filtroAvanzado: _filtroAvanzado,
          busqueda: _busqueda,
          conteosPorAsesor: _conteosPorAsesor,
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

  /// Único punto que arma la consulta al SP: chip + tarjetas + panel +
  /// búsqueda viajan juntos en TODAS las páginas. Si una página siguiente
  /// saliera sin alguno, mezclaría filas filtradas con sin filtrar (el cursor
  /// keyset solo vale para la misma combinación de filtros).
  Future<CobranzaPagina> _pedirPagina({
    required CobranzaChipFiltro chip,
    String? codAsesor,
    String? cursorFecha,
    String? cursorNumSol,
    required int tamanio,
  }) => _getPagina(
    chip: chip,
    codAsesor: codAsesor,
    cursorFecha: cursorFecha,
    cursorNumSol: cursorNumSol,
    tamanio: tamanio,
    fcDesde: _filtroAvanzado.desdeEfectivo,
    fcHasta: _filtroAvanzado.hastaEfectivo,
    idCampania: _filtroAvanzado.idCampania,
    idOportunidad: _filtroAvanzado.idOportunidad,
    estados: _estados,
    busqueda: _busqueda,
  );

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
      final pagina = await _pedirPagina(
        chip: s.chipFiltro,
        codAsesor: s.asesorSeleccionado,
        cursorFecha: s.cursorFecha,
        cursorNumSol: s.cursorNumSol,
        tamanio: CobranzaRemoteDatasource.tamanioSiguiente,
      );
      if (epoca != _epoca || emit.isDone) return;

      final yaCargados = s.items.map((c) => c.numSol).toSet();
      final nuevos =
          pagina.items.where((c) => !yaCargados.contains(c.numSol)).toList();
      final items = [...s.items, ...nuevos];

      emit(
        s.copyWith(
          items: items,
          // conteosPorAsesor NO se recalcula: ya vino completo del SP en la
          // primera página, sumar las páginas nuevas lo duplicaría.
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
    final i = s.items.indexWhere((c) => c.numSol == event.numSol);
    if (i < 0) return;

    final anterior = s.items[i];
    final label = cobranzaEstadoLabel(event.idEstado);
    final items = List<Cobranza>.of(s.items);
    items[i] = anterior.copyWith(
      idEstado: event.idEstado,
      estado: label.isNotEmpty ? label : null,
      idCondicion: event.idCondicion,
      condicion: event.condicion,
    );

    // El mapa del picker viene del SP, así que acá solo se PARCHA la fila que
    // cambió (recalcularlo sobre `items` lo dejaría otra vez en los conteos de
    // las páginas cargadas).
    _conteosPorAsesor = _moverConteo(
      _conteosPorAsesor,
      codUser: anterior.asignadoA,
      estadoAnterior: anterior.idEstado,
      estadoNuevo: event.idEstado,
    );
    emit(s.copyWith(items: items, conteosPorAsesor: _conteosPorAsesor));
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Mueve 1 del estado anterior al nuevo dentro del mapa del picker, para no
  /// tener que volver a pedir la primera página cuando se factura desde el
  /// detalle.
  Map<String, Map<int, int>> _moverConteo(
    Map<String, Map<int, int>> actual, {
    required String codUser,
    required int estadoAnterior,
    required int estadoNuevo,
  }) {
    if (codUser.isEmpty || estadoAnterior == estadoNuevo) return actual;
    final copia = {
      for (final e in actual.entries) e.key: Map<int, int>.of(e.value),
    };
    final porEstado = copia.putIfAbsent(codUser, () => {});
    final restante = (porEstado[estadoAnterior] ?? 0) - 1;
    if (restante > 0) {
      porEstado[estadoAnterior] = restante;
    } else {
      porEstado.remove(estadoAnterior);
    }
    porEstado[estadoNuevo] = (porEstado[estadoNuevo] ?? 0) + 1;
    return copia;
  }

  /// Solo como respaldo cuando el SP no manda el bloque porAsesor: suma sobre
  /// las filas ya cargadas (el comportamiento viejo, incompleto por diseño).
  Map<String, Map<int, int>> _conteosPorAsesorLocal(List<Cobranza> items) {
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
