// lib/features/solicitudes/presentation/bloc/list/solicitud_list_bloc.dart
//
// BLoC de Solicitudes paginado (task 'LSP'). Mismo patrón que SeguimientoBloc:
//   - "restartable" (chip / filtro / refresh / búsqueda): contador [_epoca].
//   - "droppable" (página siguiente): flag síncrono [_cargandoPagina].
//   - "debounce" (buscador del AppBar): ticket [_ticketBusqueda], mismo estilo
//     que [_epoca] — cada tecla saca uno nuevo y tras la espera solo sigue el
//     último.
//   - recarga parcial: si ya hay SolicitudListSuccess, se emite con
//     recargandoLista:true (chips + contadores quedan montados).
// La búsqueda de texto la aplica el SP (campo 12 del 'LSP'), igual que
// Seguimiento — antes se filtraba en cliente y solo encontraba en las páginas
// ya cargadas.

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListBloc extends Bloc<SolicitudListEvent, SolicitudListState> {
  final GetSolicitudPaginaUseCase _getPagina;

  List<Solicitud> _items = [];
  SolicitudFiltro _filtro = SolicitudFiltro.todas;
  String? _asesorSeleccionado;
  // Texto del buscador ya normalizado ('' = sin búsqueda). Se combina con chip
  // + panel (AND en el SP) y viaja en TODAS las páginas — ver [_pedirPagina].
  String _busqueda = '';
  int _ticketBusqueda = 0;
  SolicitudFiltroAvanzado _filtroAvanzado =
      SolicitudFiltroAvanzado.porDefecto();
  SolicitudConteos _conteos = const SolicitudConteos();
  // {codUser: {ibValidado: cantidad}} del picker "Asesores". Lo manda el SP en
  // la primera página sobre TODO el universo filtrado — antes se sumaba acá
  // sobre `_items` (las páginas ya cargadas) y un asesor con 141 filas mostraba
  // las 9 que habían entrado en la primera página.
  Map<String, Map<bool, int>> _conteosPorAsesor = const {};
  int _epoca = 0;
  bool _cargandoPagina = false;
  String? _cursorFecha;
  String? _cursorNumsol;
  bool _finLista = false;

  SolicitudListBloc(this._getPagina) : super(const SolicitudListInitial()) {
    on<SolicitudListStarted>(_onStarted);
    on<SolicitudListRefresh>(_onRefresh);
    on<SolicitudListFiltered>(_onFiltered);
    on<SolicitudListAsesorSeleccionado>(_onAsesorSeleccionado);
    on<SolicitudListSearched>(_onSearched);
    on<SolicitudFiltroAvanzadoAplicado>(_onFiltroAvanzadoAplicado);
    on<SolicitudFiltroAvanzadoLimpiado>(_onFiltroAvanzadoLimpiado);
    on<SolicitudPaginaSolicitada>(_onPaginaSolicitada);
    on<SolicitudReintentarPagina>(_onReintentarPagina);
  }

  String _chipCode(SolicitudFiltro f) => switch (f) {
    SolicitudFiltro.sinValidar => 'SV',
    SolicitudFiltro.enviarACobranza => 'VA',
    _ => '',
  };

  String? get _asesorParam =>
      _filtro == SolicitudFiltro.asesores ? _asesorSeleccionado : null;

  // ── Carga desde cero ──────────────────────────────────────────────────────

  Future<void> _onStarted(
    SolicitudListStarted e,
    Emitter<SolicitudListState> emit,
  ) => _cargarDesdeCero(emit);

  Future<void> _onRefresh(
    SolicitudListRefresh e,
    Emitter<SolicitudListState> emit,
  ) => _cargarDesdeCero(emit);

  Future<void> _onFiltered(
    SolicitudListFiltered e,
    Emitter<SolicitudListState> emit,
  ) {
    if (e.filtro == _filtro && state is SolicitudListSuccess) {
      return Future.value();
    }
    _filtro = e.filtro;
    if (_filtro != SolicitudFiltro.asesores) _asesorSeleccionado = null;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onAsesorSeleccionado(
    SolicitudListAsesorSeleccionado e,
    Emitter<SolicitudListState> emit,
  ) {
    _asesorSeleccionado = e.codAsesor;
    _filtro = SolicitudFiltro.asesores;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onSearched(
    SolicitudListSearched e,
    Emitter<SolicitudListState> emit,
  ) async {
    final texto = e.query.trim();

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
    if (busqueda == _busqueda && state is SolicitudListSuccess) return;
    _busqueda = busqueda;
    await _cargarDesdeCero(emit);
  }

  Future<void> _onFiltroAvanzadoAplicado(
    SolicitudFiltroAvanzadoAplicado e,
    Emitter<SolicitudListState> emit,
  ) {
    _filtroAvanzado = e.filtro;
    return _cargarDesdeCero(emit);
  }

  Future<void> _onFiltroAvanzadoLimpiado(
    SolicitudFiltroAvanzadoLimpiado e,
    Emitter<SolicitudListState> emit,
  ) {
    final def = SolicitudFiltroAvanzado.porDefecto();
    if (_filtroAvanzado == def && state is SolicitudListSuccess) {
      return Future.value();
    }
    _filtroAvanzado = def;
    return _cargarDesdeCero(emit);
  }

  Future<void> _cargarDesdeCero(Emitter<SolicitudListState> emit) async {
    final epoca = ++_epoca;
    _cargandoPagina = false;

    final actual = state;
    if (actual is SolicitudListSuccess) {
      emit(actual.copyWith(recargandoLista: true, limpiarLoadMoreError: true));
    } else {
      emit(const SolicitudListLoading());
    }

    try {
      final pagina = await _pedirPagina(
        tamanio: SolicitudRemoteDatasource.tamanioPrimera,
      );
      if (epoca != _epoca || emit.isDone) return;

      _items = pagina.items;
      _conteos = pagina.conteos ?? const SolicitudConteos();
      // Fallback al cálculo viejo (sobre lo cargado) solo si el SP no trae el
      // bloque — app nueva contra un SP aún no desplegado.
      _conteosPorAsesor =
          pagina.conteosPorAsesor ?? _conteosPorAsesorLocal(pagina.items);
      _cursorFecha = pagina.cursorFecha;
      _cursorNumsol = pagina.cursorNumsol;
      _finLista =
          pagina.items.length < SolicitudRemoteDatasource.tamanioPrimera;
      _emitir(emit, recargando: false);
    } catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      emit(SolicitudListError(_msg(e)));
    }
  }

  /// Único punto que arma la consulta al SP: chip + panel + búsqueda viajan
  /// juntos en TODAS las páginas. Si una página siguiente saliera sin alguno,
  /// mezclaría filas filtradas con sin filtrar (el cursor keyset solo vale
  /// para la misma combinación de filtros).
  Future<SolicitudPagina> _pedirPagina({
    String? cursorFecha,
    String? cursorNumsol,
    required int tamanio,
  }) => _getPagina(
    chip: _chipCode(_filtro),
    idAsesor: _asesorParam,
    cursorFecha: cursorFecha,
    cursorNumsol: cursorNumsol,
    tamanio: tamanio,
    fcDesde: _filtroAvanzado.desdeEfectivo,
    fcHasta: _filtroAvanzado.hastaEfectivo,
    idCampania: _filtroAvanzado.idCampania,
    idOportunidad: _filtroAvanzado.idOportunidad,
    busqueda: _busqueda,
  );

  // ── Página siguiente ──────────────────────────────────────────────────────

  Future<void> _onPaginaSolicitada(
    SolicitudPaginaSolicitada e,
    Emitter<SolicitudListState> emit,
  ) async {
    final s = state;
    if (s is! SolicitudListSuccess || s.recargandoLista) return;
    if (s.loadMoreError != null || !s.puedePaginar) return;
    await _traerSiguiente(emit);
  }

  Future<void> _onReintentarPagina(
    SolicitudReintentarPagina e,
    Emitter<SolicitudListState> emit,
  ) async {
    final s = state;
    if (s is! SolicitudListSuccess || s.cargandoMas || _finLista) return;
    if (_cursorFecha == null) return;
    _emitir(emit, limpiarLoadMoreError: true);
    await _traerSiguiente(emit);
  }

  Future<void> _traerSiguiente(Emitter<SolicitudListState> emit) async {
    if (_cargandoPagina) return;
    _cargandoPagina = true;
    final epoca = _epoca;
    _emitir(emit, cargandoMas: true, limpiarLoadMoreError: true);

    try {
      final pagina = await _pedirPagina(
        cursorFecha: _cursorFecha,
        cursorNumsol: _cursorNumsol,
        tamanio: SolicitudRemoteDatasource.tamanioSiguiente,
      );
      if (epoca != _epoca || emit.isDone) return;

      final ids = _items.map((s) => s.idSolicitud).toSet();
      final nuevos =
          pagina.items.where((s) => !ids.contains(s.idSolicitud)).toList();
      _items = [..._items, ...nuevos];
      _cursorFecha = pagina.cursorFecha ?? _cursorFecha;
      _cursorNumsol = pagina.cursorNumsol ?? _cursorNumsol;
      _finLista =
          pagina.items.length < SolicitudRemoteDatasource.tamanioSiguiente;
      _emitir(emit, cargandoMas: false);
    } catch (e) {
      if (epoca != _epoca || emit.isDone) return;
      _emitir(emit, cargandoMas: false, loadMoreError: _msg(e));
    } finally {
      _cargandoPagina = false;
    }
  }

  // ── Emisión ──────────────────────────────────────────────────────────────

  Map<String, Map<bool, int>> _conteosPorAsesorLocal(List<Solicitud> items) {
    final conteos = <String, Map<bool, int>>{};
    for (final s in items) {
      if (s.asesor.isEmpty) continue;
      final m = conteos.putIfAbsent(s.asesor, () => {});
      m[s.ibValidado] = (m[s.ibValidado] ?? 0) + 1;
    }
    return conteos;
  }

  void _emitir(
    Emitter<SolicitudListState> emit, {
    bool? recargando,
    bool? cargandoMas,
    String? loadMoreError,
    bool limpiarLoadMoreError = false,
  }) {
    emit(
      SolicitudListSuccess(
        solicitudes: _items,
        filtro: _filtro,
        asesorSeleccionado: _asesorSeleccionado,
        filtroAvanzado: _filtroAvanzado,
        busqueda: _busqueda,
        cntSinValidar: _conteos.sinValidar,
        cntValidados: _conteos.validados,
        conteosPorAsesor: _conteosPorAsesor,
        recargandoLista: recargando ?? false,
        finLista: _finLista,
        cargandoMas: cargandoMas ?? false,
        loadMoreError: limpiarLoadMoreError ? null : loadMoreError,
        cursorFecha: _cursorFecha,
        cursorNumsol: _cursorNumsol,
      ),
    );
  }

  String _msg(Object e) =>
      e is AppException ? e.message : 'No se pudo cargar las solicitudes.';
}
