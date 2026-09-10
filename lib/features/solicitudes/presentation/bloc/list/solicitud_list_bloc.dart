// lib/features/solicitudes/presentation/bloc/list/solicitud_list_bloc.dart
//
// BLoC de Solicitudes paginado (task 'LSP'). Mismo patrón que SeguimientoBloc:
//   - "restartable" (chip / filtro / refresh): contador [_epoca].
//   - "droppable" (página siguiente): flag síncrono [_cargandoPagina].
//   - recarga parcial: si ya hay SolicitudListSuccess, se emite con
//     recargandoLista:true (chips + contadores quedan montados).
// La búsqueda de texto se aplica en cliente sobre las páginas ya cargadas.

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
import 'package:app_crm/features/solicitudes/index_solicitudes.dart';

class SolicitudListBloc extends Bloc<SolicitudListEvent, SolicitudListState> {
  final GetSolicitudPaginaUseCase _getPagina;

  List<Solicitud> _items = [];
  SolicitudFiltro _filtro = SolicitudFiltro.todas;
  String? _asesorSeleccionado;
  String _busqueda = '';
  SolicitudFiltroAvanzado _filtroAvanzado =
      SolicitudFiltroAvanzado.porDefecto();
  SolicitudConteos _conteos = const SolicitudConteos();
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
  ) {
    _busqueda = e.query;
    if (state is SolicitudListSuccess) _emitir(emit);
    return Future.value();
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
      final pagina = await _getPagina(
        chip: _chipCode(_filtro),
        idAsesor: _asesorParam,
        cursorFecha: null,
        cursorNumsol: null,
        tamanio: SolicitudRemoteDatasource.tamanioPrimera,
        fcDesde: _filtroAvanzado.desdeEfectivo,
        fcHasta: _filtroAvanzado.hastaEfectivo,
        idCampania: _filtroAvanzado.idCampania,
        idOportunidad: _filtroAvanzado.idOportunidad,
      );
      if (epoca != _epoca || emit.isDone) return;

      _items = pagina.items;
      _conteos = pagina.conteos ?? const SolicitudConteos();
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
      final pagina = await _getPagina(
        chip: _chipCode(_filtro),
        idAsesor: _asesorParam,
        cursorFecha: _cursorFecha,
        cursorNumsol: _cursorNumsol,
        tamanio: SolicitudRemoteDatasource.tamanioSiguiente,
        fcDesde: _filtroAvanzado.desdeEfectivo,
        fcHasta: _filtroAvanzado.hastaEfectivo,
        idCampania: _filtroAvanzado.idCampania,
        idOportunidad: _filtroAvanzado.idOportunidad,
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

  void _emitir(
    Emitter<SolicitudListState> emit, {
    bool? recargando,
    bool? cargandoMas,
    String? loadMoreError,
    bool limpiarLoadMoreError = false,
  }) {
    final q = _busqueda.toLowerCase().trim();
    final visibles = q.isEmpty
        ? _items
        : _items
              .where(
                (s) =>
                    s.nombre.toLowerCase().contains(q) ||
                    s.apellidos.toLowerCase().contains(q) ||
                    s.nombreEmpresa.toLowerCase().contains(q) ||
                    s.telefono.contains(q) ||
                    s.idSolicitud.toLowerCase().contains(q),
              )
              .toList();

    final conteosPorAsesor = <String, Map<bool, int>>{};
    for (final s in _items) {
      if (s.asesor.isEmpty) continue;
      final m = conteosPorAsesor.putIfAbsent(s.asesor, () => {});
      m[s.ibValidado] = (m[s.ibValidado] ?? 0) + 1;
    }

    emit(
      SolicitudListSuccess(
        solicitudes: visibles,
        filtro: _filtro,
        asesorSeleccionado: _asesorSeleccionado,
        filtroAvanzado: _filtroAvanzado,
        cntSinValidar: _conteos.sinValidar,
        cntValidados: _conteos.validados,
        conteosPorAsesor: conteosPorAsesor,
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
