// lib/features/cobranza/presentation/bloc/lista/cobranza_list_bloc.dart

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/features/cobranza/index_cobranza.dart';

class CobranzaListBloc extends Bloc<CobranzaListEvent, CobranzaListState> {
  final GetCobranzasUseCase _getCobranzasUseCase;

  List<Cobranza> _allCobranzas = [];
  CobranzaChipFiltro _chipFiltro = CobranzaChipFiltro.todos;
  String? _asesorSeleccionado;

  // Set vacío = todos los estados activos (ninguna tarjeta filtrada)
  Set<int> _estadosSeleccionados = {};

  // ID_ESTADO_GES crudo: 2=Facturar 0=Pend.deDocumento 5=Pend.factura 3=Cancelado
  static const _todosLosEstados = {2, 0, 5, 3};

  CobranzaListBloc(this._getCobranzasUseCase) : super(const CobranzaListInitial()) {
    on<CobranzaListStarted>(_onStarted);
    on<CobranzaListRefresh>(_onRefresh);
    on<CobranzaChipChanged>(_onChipChanged);
    on<CobranzaEstadoToggled>(_onEstadoToggled);
    on<CobranzaAsesorSeleccionado>(_onAsesorSeleccionado);
  }

  Future<void> _onStarted(
    CobranzaListStarted event,
    Emitter<CobranzaListState> emit,
  ) async {
    emit(const CobranzaListLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    CobranzaListRefresh event,
    Emitter<CobranzaListState> emit,
  ) async {
    emit(const CobranzaListLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<CobranzaListState> emit) async {
    try {
      _allCobranzas = await _getCobranzasUseCase();
      _emitFiltered(emit);
    } catch (e, stackTrace) {
      addError(e, stackTrace);
      emit(CobranzaListError(e.toString()));
    }
  }

  void _onChipChanged(CobranzaChipChanged event, Emitter<CobranzaListState> emit) {
    _chipFiltro = event.filtro;
    if (_chipFiltro != CobranzaChipFiltro.asesores) _asesorSeleccionado = null;
    _emitFiltered(emit);
  }

  void _onAsesorSeleccionado(
    CobranzaAsesorSeleccionado event,
    Emitter<CobranzaListState> emit,
  ) {
    _asesorSeleccionado = event.codAsesor;
    _chipFiltro = CobranzaChipFiltro.asesores;
    _emitFiltered(emit);
  }

  void _onEstadoToggled(CobranzaEstadoToggled event, Emitter<CobranzaListState> emit) {
    final id = event.idEstado;
    final actuales = Set<int>.from(
      _estadosSeleccionados.isEmpty ? _todosLosEstados : _estadosSeleccionados,
    );

    if (actuales.contains(id)) {
      // No permitir deseleccionar el último estado activo
      if (actuales.length == 1) return;
      actuales.remove(id);
    } else {
      actuales.add(id);
    }

    // Si están todos activos, volvemos a set vacío (= sin filtro de estado)
    _estadosSeleccionados =
        actuales.length == _todosLosEstados.length ? {} : actuales;

    _emitFiltered(emit);
  }

  void _emitFiltered(Emitter<CobranzaListState> emit) {
    // 1. Aplicar filtro de chip
    var porChip = List<Cobranza>.from(_allCobranzas);
    if (_chipFiltro == CobranzaChipFiltro.asesores) {
      porChip = porChip.where((c) => c.asignadoA == _asesorSeleccionado).toList();
    } else if (_chipFiltro == CobranzaChipFiltro.contado) {
      porChip = porChip.where((c) => c.idCondicion == 'C').toList();
    } else if (_chipFiltro == CobranzaChipFiltro.credito) {
      porChip = porChip.where((c) => c.idCondicion == 'CR').toList();
    }

    // 2. Conteos por estado sobre lista ya filtrada por chip (antes del filtro de tarjetas)
    final conteos = <int, int>{
      2: porChip.where((c) => c.idEstado == 2).length,
      0: porChip.where((c) => c.idEstado == 0).length,
      5: porChip.where((c) => c.idEstado == 5).length,
      3: porChip.where((c) => c.idEstado == 3).length,
    };

    // 3. Aplicar filtro de estados (tarjetas)
    var resultado = porChip;
    if (_estadosSeleccionados.isNotEmpty) {
      resultado = porChip.where((c) => _estadosSeleccionados.contains(c.idEstado)).toList();
    }

    emit(
      CobranzaListSuccess(
        cobranzas: resultado,
        chipFiltro: _chipFiltro,
        estadosSeleccionados: Set.from(_estadosSeleccionados),
        conteosPorEstado: conteos,
        asesorSeleccionado: _asesorSeleccionado,
        conteosPorAsesor: _buildConteosPorAsesor(),
      ),
    );
  }

  // Conteo de cobranzas por asesor (codUser) sobre el total cargado —
  // alimenta CobranzaAsesorPickerModal, no viene del backend
  Map<String, int> _buildConteosPorAsesor() {
    final conteos = <String, int>{};
    for (final c in _allCobranzas) {
      if (c.asignadoA.isEmpty) continue;
      conteos[c.asignadoA] = (conteos[c.asignadoA] ?? 0) + 1;
    }
    return conteos;
  }
}
