// lib/features/cobranza/presentation/bloc/lista/cobranza_list_bloc.dart

import 'dart:async';

import 'package:app_crm/index_dependencies.dart';
import 'package:app_crm/core/index_core.dart';
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

  StreamSubscription<CobranzaUpdate>? _updateSub;

  CobranzaListBloc(this._getCobranzasUseCase) : super(const CobranzaListInitial()) {
    on<CobranzaListStarted>(_onStarted);
    on<CobranzaListRefresh>(_onRefresh);
    on<CobranzaChipChanged>(_onChipChanged);
    on<CobranzaEstadoToggled>(_onEstadoToggled);
    on<CobranzaAsesorSeleccionado>(_onAsesorSeleccionado);
    on<CobranzaListItemActualizado>(_onItemActualizado);

    _updateSub = CobranzaUpdateNotifier.instance.stream.listen((update) {
      if (!isClosed) {
        add(CobranzaListItemActualizado(update.numSol, update.idEstado));
      }
    });
  }

  @override
  Future<void> close() {
    _updateSub?.cancel();
    return super.close();
  }

  void _onItemActualizado(
    CobranzaListItemActualizado event,
    Emitter<CobranzaListState> emit,
  ) {
    final label = cobranzaEstadoLabel(event.idEstado);
    _allCobranzas = _allCobranzas
        .map(
          (c) => c.numSol == event.numSol
              ? c.copyWith(
                  idEstado: event.idEstado,
                  estado: label.isNotEmpty ? label : null,
                )
              : c,
        )
        .toList();
    _emitFiltered(emit);
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

    // Pend. de documento (idEstado 0) sobre TODO lo cargado, sin filtro de
    // chip — alimenta el badge del drawer, que no debe variar según qué
    // chip esté activo en esta pantalla (mismo criterio que TOT_COBRANZA
    // del SP de home).
    final pendientesDocumento =
        _allCobranzas.where((c) => c.idEstado == 0).length;

    emit(
      CobranzaListSuccess(
        cobranzas: resultado,
        chipFiltro: _chipFiltro,
        estadosSeleccionados: Set.from(_estadosSeleccionados),
        conteosPorEstado: conteos,
        pendientesDocumento: pendientesDocumento,
        asesorSeleccionado: _asesorSeleccionado,
        conteosPorAsesor: _buildConteosPorAsesor(),
      ),
    );
  }

  // Conteo de cobranzas por asesor (codUser), desglosado por idEstado, sobre
  // el total cargado — alimenta CobranzaAsesorPickerModal, no viene del
  // backend. Antes era un total plano (Map<String,int>) — el usuario pidió
  // ver también en qué estado está cada cobranza de ese asesor, no solo
  // cuántas tiene.
  Map<String, Map<int, int>> _buildConteosPorAsesor() {
    final conteos = <String, Map<int, int>>{};
    for (final c in _allCobranzas) {
      if (c.asignadoA.isEmpty) continue;
      final porEstado = conteos.putIfAbsent(c.asignadoA, () => {});
      porEstado[c.idEstado] = (porEstado[c.idEstado] ?? 0) + 1;
    }
    return conteos;
  }
}
